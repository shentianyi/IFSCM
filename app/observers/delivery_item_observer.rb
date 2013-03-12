class DeliveryItemObserver < ActiveRecord::Observer
  
  def after_create( dit )
    return true  unless order = OrderItem.find_by_id( dit.delivery_package.order_item_id )
    amount = dit.delivery_package.perPackAmount
    order.rest -= amount
    order.transit += amount
    order.save
  end
  
  def after_update( dit )
    return true  unless order = OrderItem.find_by_id( dit.delivery_package.order_item_id )
    return true  unless arr = dit.wayState_change
    amount = dit.delivery_package.perPackAmount
    origin = arr.first
    current = arr.last
    if current == DeliveryObjWayState::Intransit
      order.rest -= amount
      order.transit += amount
    elsif current == DeliveryObjWayState::Received
      order.transit -= amount
      order.receipt += amount
    else
      order.transit -= amount
      order.rest += amount
    end
    order.save
  end
  
end
