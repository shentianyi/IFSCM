class DeliveryItemState < ActiveRecord::Base
  attr_accessible :state, :desc
  
  belongs_to :delivery_item
end
