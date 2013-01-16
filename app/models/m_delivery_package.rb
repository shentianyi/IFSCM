class MDeliveryPackage < ActiveRecord::Base
  belongs_to :m_delivery_note
  attr_accessible :cpartNr, :key,:parentKey,:packAmount, :partRelMetaKey, :perPackAmount, :purchaseNo, :saleNo, :spartNr, :total
  has_many :m_delivery_items,:dependent=>:destroy
end
