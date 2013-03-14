class AddOrderNrAndOrderItemIdToDeliveryPackages < ActiveRecord::Migration
  def change
    add_column :delivery_packages, :orderNr,:string
    add_column :delivery_packages, :order_item_id, :integer
    add_index :delivery_packages, [:order_item_id], :name => "index_delivery_packages_on_order_item_id"
  end
end
