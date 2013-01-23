#coding:utf-8
require 'base_class'
require 'base_delivery'

class DeliveryItem < ActiveRecord::Base
  attr_accessible :key,  :parentKey,:state
  attr_accessible :id, :created_at, :updated_at,:delivery_package_id
  belongs_to :delivery_packages
  include CZ::BaseModule
  include CZ::DeliveryBase
end
