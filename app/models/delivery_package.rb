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
  
  
  after_save :update_redis_id
    
  def self.single_or_default key
    find_from_redis key
  end
  
  private
  def self.find_from_redis key
    rfind(key)
  end
end