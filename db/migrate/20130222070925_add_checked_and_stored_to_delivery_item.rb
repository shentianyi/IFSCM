class AddCheckedAndStoredToDeliveryItem < ActiveRecord::Migration
  def change
     add_column :delivery_items, :checked, :boolean,:default=>false
     add_column :delivery_items, :stored, :boolean,:default=>false
  end
end
