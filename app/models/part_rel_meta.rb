require 'base_class'

class PartRelMeta<CZ::BaseClass
  attr_accessor :key,:cpartId,:spartId,:saleNo,:purchaseNo

  # ---------------------------------------------
  #ws : for redis search
  include Redis::Search
  redis_search_index(:title_field => :key,
                     :alias_field => :alias,
                     :prefix_index_enable => true,
                     :condition_fields=>[:orgIds],
                     :ext_fields => [:cpartId,:spartId,:saleNo,:purchaseNo])
  def alias
    cpart=Part.find(cpartId)
    spart=Part.find(spartId)
    [cpart.partNr,spart.partNr,self.saleNo,self.purchaseNo]
  end

  def orgIds
    orgids=[]
    orgids<<Part.find(self.cpartId).orgId
    orgids<<Part.find(self.spartId).orgId
    orgids
  end
#-----------------------------

  def self.gen_key
    "partrelmeta:#{$redis.incr('partrelmeta_index_incr')}"
  end
  
  # ws
  # [功能：] 将PartRelMeta加入到 Org-CS-RelMeta Set
  # 参数：
  # - int - orgId
  # - int - partnerNr
  # - PartRelType : partRelType
  # 返回值：
  # - 无
  def add_to_org_relmeta_set orgId,partnerId,partRelType
    set_key=PartRelMeta.generate_org_relmeta_set orgId,partnerId,partRelType
    $redis.sadd set_key,self.key
  end
  
  # ws
  # [功能：] 将PartRelMeta加入到 Org-Part-RelMeta Set
  # 参数：
  # - int - clientId
  # - int - supplierId
  # - string : partKey
  # 返回值：
  # - 无
  def add_to_org_part_relmeta_set clientId,supplierId,partKey
    set_key=PartRelMeta.generate_cs_partRel_meta_set_key clientId,supplierId,partKey
    $redis.sadd set_key,self.key
  end
    
  # ws
  # [功能：] 分页获取组织关系零件关系元数组及总数
  # 参数：
  # - int - orgId
  # - int - partnerId
  # - PartRelType : partRelType
  # - int : startIndex, 可空
  # - int ： endIndex, 可空
  # 返回值：
  # - Array : 零件关系元数组   
  # - int : 总数
  def self.get_by_parterId orgId,partnerId,partRelType,startIndex=nil,endIndex=nil
     zset_key=PartRelMeta.generate_org_relmeta_zset orgId,partRelType
     total=$redis.zcount zset_key,partnerId,partnerId
     if total>0
       # metaKeys=
     end
     return nil
  end
    
  def self.generate_cs_partRel_meta_set_key cid,sid,partKey
    "clientId:#{cid}:supplierId:#{sid}:#{partKey}:metaset"
  end
  
  private 
  
   def self.generate_org_relmeta_set cid,sid,partRelType
    "clientId:#{cid}:supplierId:#{sid}::relType:#{PartRelType.get_by_value(partRelType)}:relmetaset"
  end

  
end