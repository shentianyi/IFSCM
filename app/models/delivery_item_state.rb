#encoding: utf-8
class DeliveryItemState < ActiveRecord::Base
  attr_accessible :state, :desc
  attr_accessible :delivery_item_id,:id
  belongs_to :delivery_item
end



