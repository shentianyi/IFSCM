#encoding: utf-8
require 'base_class'
require 'base_delivery'

class DeliveryItem < ActiveRecord::Base
  attr_accessible :key,  :parentKey,:state,:wayState,:tested
  attr_accessible :id, :created_at, :updated_at,:delivery_package_id
  
  belongs_to :delivery_packages
  has_one :delivery_item_state
  
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
