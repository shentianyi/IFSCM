class AddCostCenterToStorageHistory < ActiveRecord::Migration
  def change
    add_column :storage_histories, :cost_center_name, :string
  end
end
