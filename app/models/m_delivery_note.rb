class MDeliveryNote < ActiveRecord::Base
  attr_accessible :desiOrgId, :destination, :key, :orgId, :sender, :state, :wayState,:sendDate
  has_many :m_delivery_packages,:dependent=>:destroy
end
