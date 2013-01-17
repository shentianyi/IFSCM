#coding:utf-8
require 'base_class'

class PartRelMeta<CZ::BaseClass
  attr_accessor :cpartId,:spartId,:saleNo,:purchaseNo

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
  # ws
  # [功能：] 将PartRelMeta加入到 Org-CS-RelMeta ZSet
  # 参数：
  # - int - clientId
  # - int - supplierId
  # - int - partId
  # - PartRelType : partRelType
  # 返回值：
  # - 无
  def add_to_org_relmeta_zset clientId,supplierId,partId,partRelType
    zset_key=PartRelMeta.generate_org_relmeta_zset_key clientId,supplierId,partRelType
    $redis.zadd zset_key,partId,self.key
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
  # - int - cId
  # - int - sId
  # - PartRelType : partRelType
  # - int : startIndex, 可空
  # - int ： endIndex, 可空
  # 返回值：
  # - Array : 零件关系元数组
  # - int : 总数
  def self.get_by_orgId cId,sId,partRelType,startIndex=nil,endIndex=nil
    zset_key=PartRelMeta.generate_org_relmeta_zset_key cId,sId,partRelType
    total=$redis.zcard zset_key
    if total>0
      metaKeys=if startIndex
      $redis.zrange zset_key,startIndex,endIndex
      else
      $redis.zrange zset_key,0,-1
      end
      metas=[]
      metaKeys.each do |k|
        metas<<PartRelMeta.find(k)
      end
      if startIndex
      return metas,total
      end
    return metas
    end
    return nil
  end
  
  # ws
  # [功能：] 分页获取组织关系零件关系元数组及总数
  # 参数：
  # - int - cId
  # - int - sId
  # - int - partId
  # - PartRelType : partRelType
  # - int : offset, 可空
  # - int：count, 可空
  # 返回值：
  # - Array : 零件关系元数组
  # - int : 总数
  def self.get_by_partId_orgId cId,sId,partRelType,partId,offset=nil,count=nil
    zset_key=PartRelMeta.generate_org_relmeta_zset_key cId,sId,partRelType
    total=$redis.zcount zset_key,partId,partId
    if total>0
      metaKeys=if offset
        puts "partId:#{partId}"
      $redis.zrangebyscore zset_key,partId,partId,:limit=>[offset,count]
      else
      $redis.zrangebyscore zset_key,partId,partId
      end
      metas=[]
      metaKeys.each do |k|
        metas<<PartRelMeta.find(k)
      end
      if offset
      return metas,total
      end
    return metas
    end
    return nil
  end

  def self.generate_cs_partRel_meta_set_key cid,sid,partKey
    "clientId:#{cid}:supplierId:#{sid}:#{partKey}:metaset"
  end

  private

  def self.generate_org_relmeta_zset_key cid,sid,partRelType
    "clientId:#{cid}:supplierId:#{sid}:relType:#{PartRelType.get_by_value(partRelType)}:relmetazset"
  end

end