#encoding: utf-8
# ws
# 生成可辨识的唯一键
module ClassKeyHelper

  # ws map rule
  @@ruler={
    :DeliveryItemTemp=>:generate_redis_incr_key,
    :DeliveryItem=>:generate_pack_key,
    :DeliveryNote=>:generate_dn_key,
    :DeliveryPackage=>:generate_redis_incr_key,
    :DemandHistory=>:generate_uuid_key,
    :DemanderTemp=>:generate_uuid_key,
    :Demander=>:generate_redis_incr_key,
    :FileData=>:generate_redis_incr_key,
    :Organisation=>:generate_redis_incr_key,
    :PartRelMeta=>:generate_redis_incr_key,
    :PartRel=>:generate_redis_incr_key,
    :Part=>:generate_redis_incr_key,
    :RedisFile=>:generate_uuid_key,
    :OrgRelPrinter=>:generate_redis_incr_key,
    :DnContact=>:generate_redis_incr_key
  }

  def self.gen_key className
    if @@ruler.key?(className.to_sym)
    return self.send @@ruler[className.to_sym],className
    end
    return nil
  end

  def self.decompose_key className,key
    decompose_redis_incr_key(className,key)
  end

   def self.compose_key className,id
     compose_redis_incr_key className,id
   end

  private

 # 生成redis自增唯一键
  def self.generate_redis_incr_key className
    "#{className}:"+$redis.incr("#{className}_incr_index").to_s
  end
# 解析唯一键，获得id
  def self.decompose_redis_incr_key className,key
     key.delete "#{className}:"
  end
  # 根据id，class 获得键
  def self.compose_redis_incr_key className,id
     "#{className}:#{id}"
  end
  
  # 生成UUID唯一键
  def self.generate_uuid_key className=nil
    UUID.generate
  end

  # 生成运单唯一键
  def self.generate_dn_key className=nil
    "DN#{Time.now.strftime('%y%m%d')}B#{$redis.incr 'delivery_note_main_key'}"
  end

  # 生成包装箱唯一键
  def self.generate_pack_key className=nil
    "P#{Time.now.strftime('%y%m%d')}B#{$redis.incr 'delivery_package_main_key'}"
  end

end