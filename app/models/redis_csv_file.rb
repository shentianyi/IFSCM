class RedisCsvFile
  attr_accessor :index,:oriName,:uuidName,:itemCount,:errorCount,:uuidName,:normalItemKey,:errorItemKey,:repeatItemKey
  
  def initialize args={}
    if args.count>0
     args.each do |k,v|
       instance_variable_set "@#{k}",v
      end
    end
  end
  
  def save_in_redis
    $redis.hmset @index,'itemCount',@itemCount,'errorCount',@errorCount,'normalItemKey',@normalItemKey
    $redis.hmset @index,'oriName',@oriName if @oriName
    $redis.hset @index,'uuidName',@uuidName if @uuidname
    $redis.hset @index,'errorItemKey',@errorItemKey if @errorItemKey
    $redis.hset @index,'repeatItemKey',@repeatItemKey if @repeatItemKey
  end
  
  def add_error_item item_key
    $redis.sadd @errorItemKey,item_key
  end
  
  def remove_error_item item_key
    $redis.srem @errorItemKey,item_key
  end
  
  def add_normal_item score,item_key
    $redis.zadd @normalItemKey,score,item_key
  end
  
  def remove_normal_item item_key
    $redis.zrem @normalItemKey,item_key
  end
  
  def set_repeat_item repeat_key,repeat_item
    $redis.hset @repeatItemKey,repeat_key,repeat_item
  end
  
  def get_repeat_item repeat_key
    if $redis.hexists(@repeatItemKey,repeat_key)
     return $redis.hget(@repeatItemKey,repeat_key)
    end
    return nil
  end
end