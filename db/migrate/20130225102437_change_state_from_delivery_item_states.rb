class ChangeStateFromDeliveryItemStates < ActiveRecord::Migration
  def change
    change_column :delivery_item_states,:state,:integer,:default=>DeliveryObjInspectState::Normal
  end
end
