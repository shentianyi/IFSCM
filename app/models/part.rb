class Part < ActiveRecord::Base
  attr_accessible :partNr
  belongs_to :organisation
  has_many :client_part_rels, :class_name=>"PartRel", :foreign_key=>"client_part_id" # org is client
  has_many :supplier_part_rels, :class_name=>"PartRel", :foreign_key=>"supplier_part_id" # org is supplier

  after_save :add_or_update_redis_index
  after_destroy :del_redis_index
  
  
  def self.get_id_by_orgId_partNr orgId,partNr
    find_id_from_redis(orgId,partNr)
  end

  private

  def add_or_update_redis_index
    if self.partNr_change
      if self.partNr_was.nil?
        add_redis_index
      else
        update_redis_index
      end
    end
  end

  def self.find_id_from_redis orgId,partNr
    if id=$redis.hget(Part.generate_org_part_hash_key(orgId),partNr)
    id=id.to_i
    end
    return id
  end

  def self.generate_org_part_hash_key org_id
    "organisation:#{org_id}:parts:hash"
  end

  def add_redis_index
    $redis.hset Part.generate_org_part_hash_key(self.organisation_id),self.partNr,self.id
  end

  def del_redis_index
    $redis.hdel Part.generate_org_part_hash_key(self.organisation_id),self.partNr
  end

  def update_redis_index
    del_redis_index
    add_redis_index
  end
end
