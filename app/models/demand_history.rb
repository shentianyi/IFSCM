class DemandHistory
  attr_accessor :clientId,:supplierId,:cpartId,:type,:date,:rate,:timeseconds,:amount
  
  def initialize args={}
    if args.count>0
     args.each do |k,v|
       instance_variable_set "@#{k}",v
      end
    end
  end
  
  def redis_key
    "cId:#{@clientId}:spId:#{@supplierId}:partId:#{@cpartId}:type:#{@type}:date:#{@date}"
  end
  
  def get_last_item_key
    $redis.zrevrange(redis_key,0,0)
  end
  
  def calculate_rate
    item_key=get_last_item_key
    if item_key
     hamount=$redis.hget(item_key,'amount').to_i
     return (@amount-hamount)/hamount*100.round.abs
    end
    return 0
  end
  
  
end