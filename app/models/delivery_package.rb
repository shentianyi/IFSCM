#coding:utf-8
class DeliveryPackage < ActiveRecord::Base
  attr_accessible :cpartNr, :key,:parentKey,:packAmount, :partRelId, :perPackAmount, :purchaseNo, :saleNo, :spartNr, :total
  belongs_to :delivery_note
  has_many :delivery_items,:dependent=>:destroy
#   
  # def packAmount t=nil
    # return FormatHelper::get_number @packAmount,t
  # end
# 
  # def perPackAmount t=nil
    # return FormatHelper::get_number @perPackAmount,t
  # end
end