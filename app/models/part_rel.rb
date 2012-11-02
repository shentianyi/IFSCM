require 'base_class'

class PartRel<CZ::BaseClass
  attr_accessor :key,:cId,:sId,:type,:items
  # has many part rel metas
  
  def gen_key type
    @key=generate_key @cid,@sid,PartRelType.get_by_value(@type)
  end
  
  
  
  #ws get part relation id 
  def self.get_partrelId_by_partNr cid,sid,partNr,partRelType
    key=generate_key cid,sid,PartRelType.get_by_value(partRelType)
    mkey=$redis.hget key,partNr
    if $redis.exists mkey
      ms=$redis.smembers(mkey)
      if ms.count>0
        return PartRelMeta.find(ms[0]).key
      end
    end
    return nil
  end 
  
  # def get single partid cs relation partid
  # if client,find supplier's parts by clients' partId
  # if supplier, find client's parts ...
   def self.get_single_part_cs_parts clientId,supplierId,partId,partRelType
    key=generate_key( clientId,supplierId,PartRelType.get_by_value(partRelType))
    prelsetKey=$redis.hget(key,cpartId) # part rel set key
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
  def self.get_all_relationd_parts cid,sid,partRelType
     key=generate_key( cid,sid,PartRelType.get_by_value(partRelType))
     prelsetItems=$redis.hgetall(key) # part rel set key
    if prelsetItems and prelsetItems.count>0
      parts=[]
      prelsetItems.each do |k,v|
       if part=Part.find(k)    
          parts<<part
       end
      end
      return parts.count>0 ? parts : nil
    else
      return nil
    end
  end 
   
   
   
  private
  def generate_key cid,sid,partRelType
    "clientId:#{cid}:supplierId:#{sid}:#{PartRelType.get_by_value(partRelType)}"
  end
   
end