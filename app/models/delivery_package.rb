#coding:utf-8
require 'base_class'

class DeliveryPackage<DeliveryBase
  attr_accessor :saleNo,:purchaseNo,:cpartNr,:spartNr,:partRelMetaKey, :packAmount,:perPackAmount,:total
  
  def packAmount t=nil
    return FormatHelper::get_number @packAmount,t
  end

  def perPackAmount t=nil
    return FormatHelper::get_number @perPackAmount,t
  end
end