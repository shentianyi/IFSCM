#coding:utf-8
class DeliveryItemTemp<DeliveryItem
  attr_accessor :packAmount,:perPackAmount,:total

  # ws
  # [功能：] 将临时运单项加入用户 ZSet
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def add_to_staff_cache staffId
    zset_key=DeliveryItemTemp.generate_staff__zset_key staffId
    $redis.zadd zset_key,Time.now.to_i,self.key
  end

  # ws
  # [功能：] 将临时运单项从用户 ZSet 删除
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def delete_from_staff_cache staffId
    zset_key=DeliveryItemTemp.generate_staff__zset_key staffId
    $redis.zrem zset_key,self.key
  end

  # ws
  # [功能：] 获取用户所有运单项缓存
  # 参数：
  # - int - staffId
  # 返回值：
  # - Array : 运单项缓存数组
  def self.get_all_staff_cache staffId
    zset_key=generate_staff__zset_key staffId
    keys=$redis.zrange zset_key,0,-1
    if keys.count>0
      temps=[]
      keys.each do |k|
        if t=DeliveryItemTemp.find(k)
          t.spartNr=Part.find(PartRelMeta.find(t.partRelMetaKey).spartId).partNr
        temps<<t
        end
      end
      return temps.count>0 ? temps:nil
    end
    return nil
  end

  # ws
  # [功能：] 清空用户所有运单项缓存
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def self.clean_all_staff_cache staffId
    zset_key=generate_staff__zset_key staffId
    $redis.remrangebyrank zset_key,0,-1
  end


  def packAmount t=nil
    return FormatHelper::get_number @packAmount,t
  end

  def perPackAmount t=nil
    return FormatHelper::get_number @perPackAmount,t
  end
 

  private

  def self.generate_staff__zset_key staffId
    "staff:#{staffId}:deliveryitemtemp:cache:zset"
  end
end