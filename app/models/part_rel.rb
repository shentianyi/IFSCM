require 'base_class'

class PartRel<CZ::BaseClass
  attr_accessor :cId,:sId,:type,:partMetaSetKey
  

  #ws get part relation id
  def self.get_partRelMetas_by_partKey cid,sid,partKey,partRelType
    key=generate_cs_partRel_hashkey(cid,sid,partRelType)
    if pr=PartRel.find($redis.hget key,partKey)
      ms=$redis.smembers(pr.partMetaSetKey)
      if ms.count>0
        metas=[]
        ms.each do |m|
         metas<< PartRelMeta.find(m)
        end
        return metas
      end
    end
    return nil 
  end
  
  def self.get_all_partRelMetaKey_by_partNr( csid, partNr, partRelType )
    if partNr.is_a?(String)
      partKey = [Part.find_partKey_by_orgId_partNr( csid,partNr )]
    elsif partNr.is_a?(Array)
      partKey = partNr.collect{|temp|Part.find_partKey_by_orgId_partNr( csid,temp ) }
    end
    partKey=partKey.compact
    return [] unless partKey.size>0
    org = Organisation.find_by_id(csid)
    total = []
    
    if partRelType==PartRelType::Client
      for k in partKey
        $redis.zrange( org.s_key, 0, -1, :withscores=>true ).each do |item|
            key = generate_cs_partRel_hashkey( csid, item[1].to_i, partRelType )
            next if $redis.hexists( key,k )==0
            next unless pr = PartRel.find($redis.hget key,k )
            mkey=pr.partMetaSetKey
            total+=$redis.smembers(mkey) if $redis.exists mkey
        end
      end
    else
      for k in partKey
        $redis.zrange( org.c_key, 0, -1, :withscores=>true ).each do |item|
            key = generate_cs_partRel_hashkey( item[1].to_i, csid, partRelType )
            next if $redis.hexists( key,k )==0
            next unless pr = PartRel.find( $redis.hget key,k )
            mkey=pr.partMetaSetKey
            total+=$redis.smembers(mkey) if $redis.exists mkey
        end
      end
    end
    return total
  end
 
   
  # def get single partid cs relation partid
  # if client,find supplier's parts by clients' partId
  # if supplier, find client's parts ...
  def self.get_single_part_cs_parts clientId,supplierId,partKey,partRelType
    key=generate_cs_partRel_hashkey( clientId,supplierId,partRelType)
    if  pr=PartRel.find($redis.hget key,partKey)
      prelset=$redis.smembers(pr.partMetaSetKey) # part rel set
      if prelset and prelset.count>0
        parts=[]
        prelset.each do |metaKey| #part rel meta key
          if pm=PartRelMeta.find(metaKey)
            pid=partRelType==PartRelType::Client ? pm.spartId : pm.cpartId
            if part=Part.find(pid)
            parts<<part
            end
          end
        end
        return parts.count>0 ? parts : nil
      end
    end
    return nil
  end
 
  
  # ws
  # [功能：] 获取PartRel实例
  # 参数：
  # - int : clientId
  # - int : supplierId
  # - string : partKey
  # - PartRelType : partRelType
  # 返回值：
  # - PartRel : PartRel 实例 
  def self.get_cs_partRel clientId,supplierId,partKey,partRelType
    key=generate_cs_partRel_hashkey(clientId,supplierId,partRelType)
    return PartRel.find($redis.hget(key,partKey))
 end
 
  # ws
  # [功能：] 将PartRel加入到 Org-Part-Rel ZSet 
  # 参数：
  # - int : orgId
  # - string : partKey
  # - PartRelType : partRelType
  # 返回值：
  # - 无
  def add_to_org_part_zset orgId,partKey,partRelType
    zset_key=PartRel.generate_org_partRel_zset_key orgId,partKey
    $redis.zadd zset_key,partRelType,self.key
  end
  
  # ws
  # [功能：] 将PartRel加入到 Org-Part-CS Hash
  # 参数：
  # - string : partKey
  # - PartRelType : partRelType
  # 返回值：
  # - 无
  def add_to_org_cs_part_hash partKey,partRelType
    hash_key=PartRel.generate_cs_partRel_hashkey self.cId,self.sId,partRelType
    $redis.hset hash_key,partKey,self.key
  end
  
  

  private 
  def self.generate_cs_partRel_hashkey cid,sid,partRelType
    "clientId:#{cid}:supplierId:#{sid}:#{PartRelType.get_by_value(partRelType)}:relhash"
  end

  def self.generate_org_partRel_zset_key orgId,partKey
    "org:#{orgId}:partKey:#{partKey}:relzset"
  end
  
end