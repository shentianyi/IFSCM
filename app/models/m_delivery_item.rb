class MDeliveryItem < ActiveRecord::Base
  belongs_to :m_delivery_note
  attr_accessible :amount, :cpartNr, :key, :parentKey, :partRelMetaKey, :purchaseNo, :saleNo, :spartNr, :state
end
