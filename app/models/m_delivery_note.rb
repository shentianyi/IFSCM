class MDeliveryNote < ActiveRecord::Base
  attr_accessible :desiOrgId, :destination, :key, :orgId, :sender, :state, :wayState
  has_many :m_delivery_item,:dependent=>:destroy
end
