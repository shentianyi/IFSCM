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
end