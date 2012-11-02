require 'base_class'

class RedisFile<CZ::BaseClass
  attr_accessor :key,:oriName,:itemCount,:errorCount, :normalItemKey,:errorItemKey,:repeatItemKey,:items
  
  def add_item item
    @items=[] if !@items
    @items<<item
  end

  def add_error_item score,item_key
    $redis.zadd @errorItemKey,score,item_key
  end

  def remove_error_item item_key
    $redis.zrem @errorItemKey,item_key
  end

  def add_normal_item score,item_key
    $redis.zadd @normalItemKey,score,item_key
  end

  def remove_normal_item item_key
    $redis.zrem @normalItemKey,item_key
  end

  #ws remove item from error to normal
  def move_error_to_normal score,item_key
    remove_error_item item_key
    add_normal_item score,item_key
  end

  #ws remove item from normal to error
  def move_normal_to_error score,item_key
    remove_normal_item item_key
    add_error_item score,item_key
  end

  def add_repeat_item repeat_key,repeat_item
    $redis.hset @repeatItemKey,repeat_key,repeat_item
  end

  def del_repeat_item repeat_key,baseuuid=nil
    if baseuuid
      if baseuuid==$redis.hget(@repeatItemKey,repeat_key)
      $redis.hdel @repeatItemKey,repeat_key
      end
    else
    $redis.hdel @repeatItemKey,repeat_key
    end
  end

  def get_repeat_item repeat_key
    if $redis.hexists(@repeatItemKey,repeat_key)
    return $redis.hget(@repeatItemKey,repeat_key)
    end
    return nil
  end

  # ws get file error item keys
  def get_error_item_keys startIndex,endIndex
    return $redis.zrange @errorItemKey,startIndex,endIndex
  end

  # ws get file error item keys
  def get_normal_item_keys startIndex,endIndex
    return $redis.zrevrange @normalItemKey,startIndex,endIndex
  end

  # ws get file repeat item keys
  def get_repeat_item_keys
    return $redis.hgetall @repeatItemKey
  end

  #  ws get file item count
  def get_items_count item_zset_key
    @itemCount=$redis.zcard item_zset_key
  end
  
  # ws del items
  def del_items_link
    $redis.del @repeatItemKey
    $redis.del @errorItemKey
    $redis.del @normalItemKey
  end
  
end