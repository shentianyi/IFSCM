require 'base_class'

class PartRel<CZ::BaseClass
  attr_accessor :key,:cId,:sId,:type,:items
  # has many part rel metas
  
  def self.gen_key cid,sid,type
    generate_key cid,sid,type
  end
  

  #ws get part relation id 
  def self.get_partrelId_by_partKey cid,sid,partKey,partRelType
    key=generate_key cid,sid,partRelType
    mkey=$redis.hget key,partKey
    if $redis.exists mkey
      ms=$redis.smembers(mkey)
      puts 'ms---------'
      puts ms
      puts 'ms---------'
      if ms.count>0
        return PartRelMeta.find(ms[0]).key
      end
    end
    return nil
  end 
  
  def self.get_all_partrelId_by_partNr( csid, partNr, partRelType )
    partKey = Part.find_partKey_by_orgId_partNr csid,partNr
    return nil unless partKey
    org = Organisation.find_by_id(csid)
    total = []
    if partRelType==PartRelType::Client
        $redis.zrange( org.s_key, 0, -1, :withscores=>true ).each do |item|
            key = generate_key( csid, item[1].to_i, partRelType )
            mkey=$redis.hget key,partKey
            total+=$redis.smembers(mkey) if $redis.exists mkey
        end
    else
        $redis.zrange( org.c_key, 0, -1, :withscores=>true ).each do |item|
            key = generate_key( item[1].to_i, csid, partRelType )
            mkey=$redis.hget key,partKey
            total+=$redis.smembers(mkey) if $redis.exists mkey
        end
    end
    return total
  end
 
  
  # def get single partid cs relation partid
  # if client,find supplier's parts by clients' partId
  # if supplier, find client's parts ...
   def self.get_single_part_cs_parts clientId,supplierId,partKey,partRelType
    key=generate_key( clientId,supplierId,partRelType)
    prelsetKey=$redis.hget(key,partKey) # part rel set key
    if prelsetKey
      prelset=$redis.smembers(prelsetKey) # part rel set
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
      else
        return nil
      end
    else
      return nil
    end
  end
   
  # ws get all parts that has been build relations
  # cid=>clientId
  # sid=> supplierId
  def self.get_all_relation_parts cid,sid,partRelType
     key=generate_key( cid,sid,partRelType)
     partKeys=$redis.hgetall(key) # part rel set key
    if partKeys and partKeys.count>0
      parts=[]
      partKeys.each do |k,v|
       if part=Part.find(k)    
          parts<<part
       end
      end
      return parts.count>0 ? parts : nil
    else
      return nil
    end
  end 
   
   def add_partRel_meta partKey,metaKey
     # add meta to rel set
     set_key=generate_rel_set_key @cId,@sId,partKey
     $redis.sadd set_key,metaKey
     # add set key to rel
     $redis.hset @key,partKey,set_key
   end
    
  private
  def self.generate_key cid,sid,partRelType 
    "clientId:#{cid}:supplierId:#{sid}:#{PartRelType.get_by_value(partRelType)}"
  end
  
   def generate_rel_set_key cid,sid,partKey
      "clientId:#{cid}:supplierId:#{sid}:#{partKey}:set"
   end
  
   
end