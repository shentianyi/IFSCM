#encoding: utf-8

class OrganisationRelation < ActiveRecord::Base

  @@zstype={:c=>"clients:zset",:s=>"suppliers:zset"}

  attr_accessible :supplierNr, :clientNr
  attr_accessible :origin_supplier_id, :origin_client_id
  
  belongs_to :origin_supplier, :class_name=>"Organisation"#, :foreign_key=>"origin_supplier_id"
  belongs_to :origin_client, :class_name=>"Organisation"#, :foreign_key=>"origin_client_id"
  has_many :part_rels

  after_save :add_or_update_redis_index
  after_destroy :del_redis_index
  
  include Redis::Search
  redis_search_index(:title_field => :clientNr,
                     :prefix_index_enable => true,
                     :condition_fields=>[:origin_client_id, :origin_supplier_id],
                     :ext_fields => [:clientNr, :supplierNr, :id])
  
  def self.get_partnerid args
   find_partnerid_from_redis args
  end  
  
  def self.get_parterNr args
    find_partnerNr_from_redis args
  end
  
  def self.get_type_by_opetype orgOpeType
    if orgOpeType==OrgOperateType::Client
      return :s
    elsif orgOpeType==OrgOperateType::Supplier
      return :c
    end
  end
  
  private
  
  def self.find_partnerid_from_redis args
    key=generate_org_rel_zset_key(args[:oid],@@zstype[args[:pt]])
    if pid=$redis.zscore(key,args[:pnr])
      pid=pid.to_i
    end
    return pid
  end

  def self.find_partnerNr_from_redis args
    key=generate_org_rel_zset_key(args[:oid],@@zstype[args[:pt]])
    $redis.zrangebyscore(key,args[:pid],args[:pid])[0]
  end
  
  def add_or_update_redis_index
    if self.supplierNr_change
      if self.supplierNr_was.nil?
        add_redis_index @@zstype[:s]
      else
        update_redis_index @@zstype[:s]
      end
    end

    if self.clientNr_change
      if self.clientNr_was.nil?
        add_redis_index @@zstype[:c]
      else
        update_redis_index @@zstype[:c]
      end
    end
  end

  def self.generate_org_rel_zset_key orgId,type
    "org:#{orgId}:#{type}"
  end

  def add_redis_index type
    key_orgid_orgnr=generate_zset_members(type)
    $redis.zadd(key_orgid_orgnr[0],key_orgid_orgnr[1],key_orgid_orgnr[2])
  end

  def del_redis_index type=nil
    type=type.nil? ? @@zstype.values : [type]
    type.each do |t|
      key_orgid_orgnr=generate_zset_members(t)
      $redis.zrem(key_orgid_orgnr[0],key_orgid_orgnr[2])
    end
  end

  def update_redis_index type
    del_redis_index type
    add_redis_index type
  end

  def generate_zset_members type
    if type==@@zstype[:s]
      return OrganisationRelation.generate_org_rel_zset_key(self.origin_client_id,type),self.origin_supplier_id,self.supplierNr
    else
      return OrganisationRelation.generate_org_rel_zset_key(self.origin_supplier_id,type),self.origin_client_id,self.clientNr
    end
  end
end