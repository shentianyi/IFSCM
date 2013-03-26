#encoding: utf-8
require 'base_class'
require 'base_delivery'

class DeliveryItem < ActiveRecord::Base
  attr_accessible :key,  :parentKey,:state,:wayState,:checked,:stored,:posi
  attr_accessible :id, :created_at, :updated_at,:delivery_package_id

  belongs_to :delivery_package
  has_one :delivery_item_state,:dependent=>:destroy
  delegate :part_rel,:to=>:delivery_package
  delegate :delivery_note,:to=>:delivery_package
   
  include CZ::BaseModule
  include CZ::DeliveryBase
 
  after_update  :update_delivery_note_state
  before_create :build_item_state
    
  @@can_acc_rej_waystates=[DeliveryObjWayState::Intransit,DeliveryObjWayState::Arrived,DeliveryObjWayState::InAccept]
  @@can_inspect_waystates=[DeliveryObjWayState::Received]
  @@inspect_states=[DeliveryObjInspect::SamInspect,DeliveryObjInspect::FullInspect]
  @@can_instore_waystate=[DeliveryObjWayState::Received]
  @@abnormal_waystate=[DeliveryObjWayState::Rejected,DeliveryObjWayState::Returned]

  def can_accept_or_reject
    @@can_acc_rej_waystates.include?(self.wayState)
  end
  
  def can_inspect
    @@can_inspect_waystates.include?(self.wayState)
  end
  
  def can_instore
    !self.stored and (@@can_instore_waystate.include?(self.wayState) and ((@@inspect_states.include?(self.needCheck) and self.checked) or !@@inspect_states.include?(self.needCheck)))
  end
  
  def self.abnormal_waystate
    @@abnormal_waystate
  end
  
  
  private

  def update_delivery_note_state
    attr={}
    if self.checked_change
      attr[:checked]=self.checked
    end
    if self.posi_change
      attr[:posi]=self.posi
    end
    if self.stored_change
      attr[:stored]=self.stored
    end
    if attr.length>0
      self.rupdate(attr)
    end
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
  
  def build_item_state
    build_delivery_item_state(:desc=>"未检验")
  end

end
