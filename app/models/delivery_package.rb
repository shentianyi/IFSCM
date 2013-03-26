#encoding: utf-8
require 'base_class'
require 'base_delivery'

class DeliveryPackage < ActiveRecord::Base
  attr_accessible :cpartNr, :key,:parentKey,:packAmount,  :perPackAmount, :purchaseNo, :saleNo, :spartNr, :total
  attr_accessible :id, :created_at, :updated_at,:delivery_note_id,:part_rel_id,:order_item_id,:orderNr
  
  belongs_to :delivery_note
  belongs_to :order_item
  belongs_to :part_rel
  has_many :delivery_items,:dependent=>:destroy
  
  include CZ::BaseModule
  include CZ::DeliveryBase
  
end