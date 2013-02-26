#encoding: utf-8
require 'base_class'
require 'base_delivery'

class DeliveryItem < ActiveRecord::Base
  attr_accessible :key,  :parentKey,:state,:wayState,:checked,:stored
  attr_accessible :id, :created_at, :updated_at,:delivery_package_id

  belongs_to :delivery_package
  has_one :delivery_item_state
  
  include CZ::BaseModule
  include CZ::DeliveryBase

  after_save :update_redis_id
  after_update :update_state_wayState,:update_delivery_note_state
  
  
  @@acc_rej_states=[DeliveryObjWayState::Intransit,DeliveryObjWayState::Arrived]
  
  def self.single_or_default key   
    return find_from_redis key
  end

  def can_accept_or_reject
    @@acc_rej_states.include?(self.wayState)
  end
  
  private

  def update_delivery_note_state
    if self.wayState_change
      dn=self.delivery_package.delivery_note      
      if self.wayState==DeliveryObjWayState::Rejected
        if dn.state==DeliveryObjState::Normal         
          dn.update_attributes(:state=>DeliveryObjState::Abnormal,:wayState=>DeliveryObjWayState::InAccept)
        end
        total=dn.delivery_packages.sum('packAmount')
        rejected=dn.delivery_items.where(:wayState=>DeliveryObjWayState::Rejected).count
        if total==rejected
          dn.update_attributes(:wayState=>DeliveryObjWayState::Rejected)
        else
          rece_reje=dn.delivery_items.where(:wayState=>[DeliveryObjWayState::Rejected,DeliveryObjWayState::Received]).count
          if total==rece_reje
            dn.update_attributes(:wayState=>DeliveryObjWayState::Received)
          end
        end
      elsif self.wayState==DeliveryObjWayState::Received
        dn.update_attributes(:wayState=>DeliveryObjWayState::InAccept)
        if dn.delivery_packages.sum('packAmount')==dn.delivery_items.where(:wayState=>[DeliveryObjWayState::Rejected,DeliveryObjWayState::Received]).count
          dn.update_attributes(:wayState=>DeliveryObjWayState::Received)
        end
      end
    end
  end

  def self.find_from_redis key
    rfind(key)
  end
end
