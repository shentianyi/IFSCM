class AddTestedToDeliveryItem < ActiveRecord::Migration
  def change
     add_column :delivery_items, :tested, :boolean,:default=>false
  end
end
