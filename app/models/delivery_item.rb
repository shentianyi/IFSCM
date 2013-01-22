class DeliveryItem < ActiveRecord::Base
  attr_accessible :key,  :parentKey,:state
  belongs_to :delivery_packages
#  attr_accessible :amount, :cpartNr, :key, :parentKey, :partRelMetaKey, :purchaseNo, :saleNo, :spartNr, :state
  
end
