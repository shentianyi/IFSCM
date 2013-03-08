class AddTypeAndStateToWarehouses < ActiveRecord::Migration
  def change
     add_column :warehouses, :type, :integer,:default=>WarehouseType::Normal
     add_column :warehouses, :state, :integer
  end
end
