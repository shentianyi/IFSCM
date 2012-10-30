require 'base_class'

class PartRel<CZ::BaseClass
  attr_accessor :key,:cId,:sId,:type,:items
  # has many part rel metas
  
  def gen_key type
    @key=generate_key @cid,@sid,OrgRelType.get_by_value(@type)
  end
  
  def self.get_partrelId cid,sid,partNr,type
    key=generate_key cid,sid,OrgRelType.get_by_value(type)
    mkey=$redis.hget key,partNr
    if $redis.exists mkey
      ms=$redis.smembers(mkey)
      if ms.count>0
        return PartRelMeta.find(ms[0]).key
      end
    end
    return nil
  end 
 
  private
  def generate_key cid,sid,orgType
    "clientId#{cid}:supplierId:#{sid}:#{OrgRelType.get_by_value(type)}"
  end
   
end