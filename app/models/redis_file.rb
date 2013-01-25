#encoding: utf-8
require 'base_class'

class RedisFile<CZ::BaseClass
  attr_accessor :oriName,:itemCount,:errorCount, :normalItemKey,:errorItemKey,:repeatItemKey,:items,:uuidName,:finished
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
    return $redis.zrange(@errorItemKey,startIndex,endIndex),$redis.zcard(@errorItemKey)
  end

  # ws get file error item keys
  def get_normal_item_keys startIndex,endIndex
    return $redis.zrevrange(@normalItemKey,startIndex,endIndex),$redis.zcard(@normalItemKey)
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

  # ws : cache staff upload batch file key
  def add_to_staff_zset staffId
    set_key=RedisFile.generate_staff_zset_key staffId
    $redis.zadd(set_key,Time.now.to_i,@key)
  end

  # ws : get staff cache batch key
  def get_staff_batch_key staffId
    set_key=generate_staff_set_key staffId
    if (batchkey= $redis.zrevrange set_key,0,0).count>0
    return  batchkey
    end
    return nil
  end

  # ws : check staff cache file
  def self.check_staff_cache_file staffId
    set_key=generate_staff_zset_key staffId
    batchId=$redis.zrevrange set_key,0,0
    if batchId.count>0
    return batchId[0]
    end
    return nil
  end

  # ws : remove cache file from staff
  def self.remove_staff_cache_file staffId,batchFileId
    set_key=generate_staff_zset_key staffId
    $redis.zrem set_key,batchFileId
  end
  
  # def default
    # {:itemCount=>0,:errorCount=>0,:normalItemKey=>UUID.generate,:repeatItemKey=>UUID.generate,:finished=>false}
  # end

  private

  def self.generate_staff_zset_key staffId
    "staffId:#{staffId}:redisFile:cachesetkey"
  end

end