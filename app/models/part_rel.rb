#encoding: utf-8
class PartRel < ActiveRecord::Base
  attr_accessible :saleNo, :purchaseNo
  attr_accessible :client_part_id, :supplier_part_id, :organisation_relation_id
  @@stype={:c=>"clientprls:zset",:s=>"supplierprls:zset"}

  belongs_to :organisation_relation
  belongs_to :client_part, :class_name=>"Part"#, :foreign_key=>"client_part_id"
  belongs_to :supplier_part, :class_name=>"Part"#, :foreign_key=>"supplier_part_id"
  has_one :strategy

  after_create :add_redis_indexs
  after_destroy :del_redis_indexs

  def self.get_part_rel_id args
    find_prid_from_redis args
  end
  
  private

  def self.find_prid_from_redis args
    key=generate_org_partrel_zset_key(args[:cid],args[:sid],args[:pid],@@stype[args[:ot]])
    if pid=$redis.zrange(key,0,-1)[0]
     pid=pid.to_i
    end
    return pid
  end

  def add_redis_indexs
    c,s=get_client_supplier
    # add client part rel set
    add_redis_index(c.id,s.id,self.client_part_id,@@stype[:c])
    # add supplier part rel set
    add_redis_index(c.id,s.id,self.supplier_part_id,@@stype[:s])
  end

  def del_redis_indexs
    c,s=get_client_supplier
    # del client part rel set
    del_redis_index(c.id,s.id,self.client_part_id,@@stype[:c])
    # del supplier part rel set
    del_redis_index(c.id,s.id,self.supplier_part_id,@@stype[:s])
  end

  def add_redis_index *args
    $redis.zadd PartRel.generate_org_partrel_zset_key(*args),0,self.id
  end

  def del_redis_index *args
    $redis.zrem PartRel.generate_org_partrel_zset_key(args),self.id
  end

  def get_client_supplier
    return self.organisation_relation.origin_client,self.organisation_relation.origin_supplier
  end 

  def self.generate_org_partrel_zset_key *args
    "corg:#{args[0]}:sorg:#{args[1]}:part:#{args[2]}:#{args[3]}"
  end

end
