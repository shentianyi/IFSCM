class MDeliveryItem < ActiveRecord::Base
  belongs_to :m_delivery_packages
#  attr_accessible :amount, :cpartNr, :key, :parentKey, :partRelMetaKey, :purchaseNo, :saleNo, :spartNr, :state
  attr_accessible :key,  :parentKey,:state
end
