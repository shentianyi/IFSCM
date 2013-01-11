#coding:utf-8
require 'base_class'

class DeliveryBase<CZ::BaseClass
  attr_accessor :type,:amount,:parentKey,:state,:items
  # ws
  # [功能：] 将运单项加入到父级 ZSet
  # 参数：
  # - 无
  # 返回值：
  # - 无
  def add_to_parent
    key=DeliveryBase.generate_child_zset_key self.parentKey
    $redis.zadd key,self.type,self.key
  end
 
   # ws
  # [功能：] 将运单从父级中移除
  # 参数：
  # - 无
  # 返回值：
  # - 无
  def remove_from_parent
    key=DeliveryBase.generate_child_zset_key self.parentKey
    $redis.zrem key,self.key
  end
 
 
  # ws
  # [功能：] 将运单对象加入到父级 ZSet
  # 参数：
  # - int : startIndex
  # - int ： endIndex
  # 返回值：
  # - int : 子总数
  def get_children startIndex,endIndex
    key=DeliveryBase.generate_child_zset_key self.key
    total=$redis.zcard key
    if total>0
      if  (keys=$redis.zrange(key,startIndex,endIndex,:withscores=>true)).count>0
        self.items=[]
        keys.each do |k,s|
          i=eval(DeliveryHelper::delivery_obj_converter s).find(k)          
          self.items<<i
        end
        return total
      end
    end
    return nil
  end

  private

  def self.generate_child_zset_key key
    "delivery:#{key}:child:zset"
  end

end