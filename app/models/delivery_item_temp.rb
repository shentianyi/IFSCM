#encoding: utf-8
require 'base_class'

class DeliveryItemTemp<CZ::BaseClass
   attr_accessor :cpartNr, :key,:parentKey,:packAmount, :part_rel_id, :perPackAmount, :purchaseNo, :saleNo, :spartNr, :total
   
  # ws
  # [功能：] 获取第一个运单项缓存
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def self.single_or_default staffId
    zset_key=generate_staff_zset_key staffId
    find(($redis.zrange zset_key,0,0 )[0])
  end


  # ws
  # [功能：] 将临时运单项加入用户 ZSet
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def add_to_staff_cache staffId
    zset_key=DeliveryItemTemp.generate_staff_zset_key staffId
    $redis.zadd zset_key,Time.now.to_i,self.key
  end

  # ws
  # [功能：] 将临时运单项从用户 ZSet 删除
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def delete_from_staff_cache staffId
    zset_key=DeliveryItemTemp.generate_staff_zset_key staffId
    $redis.zrem zset_key,self.key
  end

  # ws
  # [功能：] 获取用户所有运单项缓存
  # 参数：
  # - int - staffId
  # 返回值：
  # - Array : 运单项缓存数组
  def self.get_staff_cache staffId,startIndex=0,endIndex=-1
    zset_key=generate_staff_zset_key staffId
    total=$redis.zcard zset_key
    if total>0
      keys=$redis.zrange zset_key,startIndex,endIndex
      temps=[]
      keys.each do |k|
        if t=DeliveryItemTemp.find(k)
          # t.spartNr=Part.find(PartRel.find(t.partRelId).supplier_part_id).partNr
          temps<<t
        end
      end
      return temps,total
    end
    return nil,nil
  end

  # ws
  # [功能：] 清空用户所有运单项缓存
  # 参数：
  # - int - staffId
  # 返回值：
  # - 无
  def self.clean_all_staff_cache staffId
    zset_key=generate_staff_zset_key staffId
    keys=$redis.zrange zset_key,0,-1
    keys.each do |key|
      $redis.del key
    end
    $redis.zremrangebyrank zset_key,0,-1
  end
  

 def packAmount t=nil
    return FormatHelper::get_number @packAmount,t
  end

  def perPackAmount t=nil
    return FormatHelper::get_number @perPackAmount,t
  end
  
  
  private

  def self.generate_staff_zset_key staffId
    "staff:#{staffId}:deliveryitemtemp:cache:zset"
  end
end