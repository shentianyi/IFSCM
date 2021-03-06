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
    return true  unless dit.wayState_changed? or dit.stored_changed?
    amount = dit.delivery_package.perPackAmount

    if dit.stored_changed?
      order.transit -= amount
      order.receipt += amount
    # elsif dit.wayState == DeliveryObjWayState::Intransit
      # order.rest -= amount
      # order.transit += amount
    # else
      # order.transit -= amount
      # order.rest += amount
    end
    order.save
  end
  
end
