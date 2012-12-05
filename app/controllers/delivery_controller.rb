#coding:utf-8

class DeliveryController < ApplicationController
  
  # ws
  # [功能：] 检查运单项缓存
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryItem : 运单项对象数组 
  def check_di_cache
    
  end
  
  # ws
  # [功能：] 检查运单缓存
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryNote : 运单对象数组 
  def check_dn_cache
    
  end
  
  # ws
  # [功能：] 添加运单项缓存
  # 参数：
  # - string : partRelMetaId
  # - int : amount
  # 返回值：
  # - ReturnMsg : JSON  
  def add_di
    
  end
  
  # ws
  # [功能：] 删除运单项缓存
  # 参数：
  # - string ： deliveryItemId
  # 返回值：
  # - ReturnMsg : JSON  
  def delete_di
    
  end
  
  # ws
  # [功能：] 取消运单
  # 参数：
  # - string ： deliveryNoteId
  # 返回值：
  # - ReturnMsg : JSON  
  def cancel_dn
    
  end
  
  # ws
  # [功能：] 生成运单
  # 参数：
  # - 无
  # 返回值：
  # - ReturnMsg : JSON  
  def build_dn
    
  end
  
  # ws
  # [功能：] 发送运单
  # 参数：
  # - string ： deliveryNoteId
  # 返回值：
  # - ReturnMsg : JSON  
  def send_dn
    
  end
  
  # ws
  # [功能：] 浏览运单
  # 参数：
  # - string ： deliveryNoteId
  # 返回值：
  # - ReturnMsg : JSON  
  def view_dn
    
  end
  
end
