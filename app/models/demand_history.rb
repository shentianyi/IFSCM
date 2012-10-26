require 'base_class'

# the score of histoty is Time.to_i
class DemandHistory<CZ::BaseClass
  attr_accessor :key,:clientId,:supplierId,:cpartId,:type,:date,:rate,:timeseconds,:amount
  
  def gen_key
    generate_key @clientId,@supplierId,@cpartId,@type,@date
  end

  def gen_rate
    @rate= (generate_rate @amount,@key)
  end

  def get_last_item_key key
    $redis.zrevrange(key,0,0)
  end

  def self.compare_rate(clientId,supplierId,cpartId,type,date,amount)
    ckey=generate_key clientId,supplierId,cpartId,type,date
    return generate_rate amount,ckey
  end

  private

  def generate_key clientId,supplierId,cpartId,type,date
    "cId:#{clientId}:spId:#{supplierId}:partId:#{cpartId}:type:#{type}:date:#{date}"
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