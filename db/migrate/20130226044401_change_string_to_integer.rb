class ChangeStringToInteger < ActiveRecord::Migration
  def change
    add_column :storages, :delivery_item_id, :integer
    add_column :storages, :state, :integer, :default=>StorageState::In
  end

end
