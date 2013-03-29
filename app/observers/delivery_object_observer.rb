#encoding: utf-8
class DeliveryObjectObserver<ActiveRecord::Observer
  observe :delivery_note,:delivery_package,:delivery_item
  
  def after_create r
    r.update_redis_id
  end
  
  def after_update r
    r.update_state_wayState
  end
end