#encoding: utf-8
require 'base_class'
require 'base_delivery'

class DeliveryNote < ActiveRecord::Base
  attr_accessible :rece_org_id, :destination, :key, :state, :wayState,:sendDate
  attr_accessible :staff_id,:organisation_id
  attr_accessible :id, :created_at, :updated_at
  
  has_many :delivery_packages,:dependent=>:destroy

  belongs_to :organisation
  belongs_to :staff
  
  include CZ::BaseModule
  include CZ::DeliveryBase
  
  after_save :update_redis_id
    
  def self.single_or_default key
    find_from_redis key
  end
  
  # ws
  # [功能：] 将运单加入用户 ZSet
  # 参数：
  # - int : staffId
  # 返回值：
  # - 无
  def add_to_staff_cache
    zset_key=DeliveryNote.generate_staff_zset_key self.staff_id
    $redis.zadd zset_key,Time.now.to_i,self.key
  end

  # ws
  # [功能：] 将运单从用户 ZSet 删除
  # 参数：
  # - 无
  # 返回值：
  # - 无
  def delete_from_staff_cache
    zset_key=DeliveryNote.generate_staff_zset_key self.staff_id
    $redis.zrem zset_key,self.key
    del_from_staff_print_queue
  end

  # ws
  # [功能：] 将运单Key加入到组织 Zset
  # 参数：
  # 返回值：
  # - 无
  def add_to_orgs
    # add to sender org zset
    key= DeliveryNote.generate_org_zset_key self.organisation_id,OrgOperateType::Supplier
    $redis.zadd key,self.organisation_id.to_i,self.key
    # add to receiver org zset
    key= DeliveryNote.generate_org_zset_key self.rece_org_id,OrgOperateType::Client
    $redis.zadd key,self.rece_org_id.to_i,self.key

    # add to queue
    self.add_to_new_queue OrgOperateType::Client
  end

  # ws
  # [功能：] 将运单Key加入到接受者组织 Zset
  # 参数：
  # - 无
  # 返回值：
  # - 无
  def add_to_new_queue orgOpeType
    key=DeliveryNote.generate_org_new_queue_zset_key self.rece_org_id,orgOpeType
    $redis.zadd key,Time.now.to_i,self.key
  end

  # ws
  # [功能：] 判断运单是否存在用户缓存
  # 参数：
  # - int : staffId
  # - string : dnKey
  # 返回值：
  # - 无
  def self.exist_in_staff_cache staffId,dnKey
    zset_key=DeliveryNote.generate_staff_zset_key staffId
    $redis.zscore zset_key,dnKey
  end

  # ws
  # [功能：] 获取用户所有运单缓存
  # 参数：
  # - int - staffId
  # 返回值：
  # - Array : 运单缓存数组
  def self.get_all_staff_cache staffId
    zset_key=generate_staff_zset_key staffId
    keys=$redis.zrange zset_key,0,-1
    if keys.count>0
      dns=[]
      keys.each do |k|
        if dn=DeliveryNote.rfind(k)
        dns<<dn
        end
      end
      return dns.count>0 ? dns:nil
    end
    return nil
  end

  # ws
  # [功能：] 获取组织新运单队列数量
  # 参数：
  # - int - orgId
  # 返回值：
  # - int : count
  def self.count_org_dn_queue orgId,orgOpeType
    key=generate_org_new_queue_zset_key orgId,orgOpeType
    $redis.zcard key
  end

  # ws
  # [功能：] 清空组织新运单队列
  # 参数：
  # - int - orgId
  # 返回值：
  # - 无
  def self.clean_org_dn_queue orgId,orgOpeType
    key=generate_org_new_queue_zset_key orgId,orgOpeType
    $redis.zremrangebyrank key,0,-1
  end

  # ws
  # [功能：] 获取组织新运单
  # 参数：
  # - int - orgId
  # - int : startIndex
  # - int ： endIndex
  # 返回值：
  # - int : 子总数
  def self.get_org_dn_queue orgId,orgOpeType,startIndex,endIndex
    key=generate_org_new_queue_zset_key orgId,orgOpeType
    total=$redis.zcard key
    if total>0
      dns=[]
      dnKeys=$redis.zrange key,startIndex,endIndex
      dnKeys.each do |dnKey|
        if dn=DeliveryNote.rfind(dnKey)
        dns<<dn
        end
      end
      return dns.count>0 ? dns:nil, total
    end
    return nil
  end
  
  def add_to_staff_print_queue
    key=DeliveryNote.generate_staff_print_set_key self.staff_id
    $redis.sadd key,self.key
  end
  def del_from_staff_print_queue
        key=DeliveryNote.generate_staff_print_set_key self.staff_id
        $redis.srem key,self.key
  end
  def self.get_all_print_dnKey staffId
    key= generate_staff_print_set_key staffId
    $redis.smembers key
  end
  private
  
  def self.find_from_redis key
    rfind(key)
  end

  def self.generate_staff_zset_key staffId
    "staff:#{staffId}:deliverynote:cache:zset"
  end

  def self.generate_org_zset_key orgId,orgOpeType
    "orgId:#{orgId}:orgRelType:#{orgOpeType}:dn:zset"
  end

  def self.generate_org_new_queue_zset_key orgId,orgOpeType
    "orgId:#{orgId}:orgOpeType:#{orgOpeType}:newDNqueue"
  end
  
  def self.generate_staff_print_set_key staffId
    "staff:#{staffId}:deliverynote:print:set"
  end
end