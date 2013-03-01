class ChangeStockToStorage < ActiveRecord::Migration
  def change
    change_column :storages, :stock, :decimal, :precision =>15, :scale=>2
  end
end
