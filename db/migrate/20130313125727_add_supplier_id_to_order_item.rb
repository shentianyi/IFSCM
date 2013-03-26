class AddSupplierIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :supplier_id, :integer
  end
end
