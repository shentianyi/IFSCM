#encoding: utf-8
class Part < ActiveRecord::Base

  attr_accessible :partNr, :desc
  attr_accessible :organisation_id
  
  belongs_to :organisation
  has_many :client_part_rels, :class_name=>"PartRel", :foreign_key=>"client_part_id",:dependent=>:destroy # org is client
  has_many :supplier_part_rels, :class_name=>"PartRel", :foreign_key=>"supplier_part_id",:dependent=>:destroy # org is supplier
  has_many :storages
  has_many :storage_histories

  after_save :add_or_update_redis_index
  after_destroy :del_redis_index
  after_update :update_part_rel_info
  include Redis::Search
  redis_search_index(:title_field => :partNr,
                     :prefix_index_enable => true,
                     :condition_fields=>[:organisation_id],
                     :ext_fields => [:partNr])
  def self.get_id orgId,partNr
    find_id_from_redis(orgId,partNr)
  end

  def self.get_partNr orgId,partId
    find_nr_from_redis(orgId,partId)
  end

  private

  def self.find_id_from_redis orgId,partNr
    if id=$redis.zscore(generate_org_part_zset_key(orgId),partNr)
    id=id.to_i
    end
    return id
  end

  def self.find_nr_from_redis orgId,partId
    $redis.zrangebyscore(generate_org_part_zset_key(orgId),partId,partId)[0]
  end

  def add_or_update_redis_index
    if self.partNr_change
      if self.partNr_was.nil?
        add_redis_index
      else
        update_redis_index
      end
    end
  end

  def self.generate_org_part_zset_key orgId
    "org:#{orgId}:parts:zset"
  end

  def add_redis_index
    $redis.zadd Part.generate_org_part_zset_key(self.organisation_id),self.id,self.partNr
  end

  def del_redis_index
    $redis.zrem Part.generate_org_part_zset_key(self.organisation_id),self.partNr
  end

  def update_redis_index
    del_redis_index
    add_redis_index
  end

  def update_part_rel_info
    if self.partNr_change
      self.client_part_rels.each do |pl|
        if pinfo=PartRelInfo.find(pl.id)
          pinfo.update(:cpartNr=>self.partNr)
        end
      end

      self.supplier_part_rels.each do |pl|
        if pinfo=PartRelInfo.find(pl.id)
          pinfo.update(:spartNr=>self.partNr)
        end
      end
    end

    if self.desc_change
      self.client_part_rels.each do |pl|
        if pinfo=PartRelInfo.find(pl.id)
          pinfo.update(:cpartDesc=>self.desc)
        end
      end

      self.supplier_part_rels.each do |pl|
        if pinfo=PartRelInfo.find(pl.id)
          pinfo.update(:spartDesc=>self.desc)
        end
      end
    end
  end
end

