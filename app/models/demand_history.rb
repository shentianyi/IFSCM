require 'base_class'

# the score of histoty is Time.to_i
class DemandHistory<CZ::BaseClass
  attr_accessor :key,:clientId,:supplierId,:relPartId,:type,:date,:rate,:timeseconds,:amount,:oldamount
  
  def gen_key
   @key= generate_key @clientId,@supplierId,@relPartId,@type,@date
  end

  def gen_rate
    @rate= (generate_rate @amount,@key)
  end
  
  def self.get_demander_keys startIndex,endIndex
    $redis.zrange(key,startIndex,endIndex)
  end
  
  def get_last_item_key key
    $redis.zrevrange(key,0,1)
  end

  def self.compare_rate(clientId,supplierId,relpartId,type,date,amount)
    ckey=generate_key clientId,supplierId,relpartId,type,date
    return generate_rate amount,ckey
  end

  private

  def generate_key clientId,supplierId,relpartId,type,date
    "cId:#{clientId}:spId:#{supplierId}:relpartId:#{relpartId}:type:#{type}:date:#{date}"
  end

  def generate_rate amount,key
    item_key=get_last_item_key,key 
    if item_key
      hamount=$redis.hget(item_key,'amount').to_i
    return (amount-hamount)/hamount*100.round.abs
    end
    return 0
  end
end