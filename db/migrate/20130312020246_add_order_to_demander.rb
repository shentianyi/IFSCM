class AddOrderToDemander < ActiveRecord::Migration
  def change
    add_column :demanders, :orderNr, :string
    add_column :demanders, :order_item_id, :integer
  end
end
