#encoding: utf-8
require 'base_class'
require 'base_delivery'

class DeliveryPackage < ActiveRecord::Base
  attr_accessible :cpartNr, :key,:parentKey,:packAmount, :partRelId, :perPackAmount, :purchaseNo, :saleNo, :spartNr, :total
  attr_accessible :id, :created_at, :updated_at,:delivery_note_id
  
  belongs_to :delivery_note
  has_many :delivery_items,:dependent=>:destroy
  include CZ::BaseModule
  include CZ::DeliveryBase
#
# def packAmount t=nil
# return FormatHelper::get_number @packAmount,t
# end
#
# def perPackAmount t=nil
# return FormatHelper::get_number @perPackAmount,t
# end
end