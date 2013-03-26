class AddWayStateToDeliveryItem < ActiveRecord::Migration
  def change
      add_column :delivery_items, :wayState, :integer,:default=>DeliveryObjWayState::Intransit
  end
end
