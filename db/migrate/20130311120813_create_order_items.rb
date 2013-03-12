class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.string :orderNr
      t.decimal :total, :precision =>15, :scale=>2, :default=>0
      t.decimal :rest, :precision =>15, :scale=>2, :default=>0
      t.decimal :transit, :precision =>15, :scale=>2, :default=>0
      t.decimal :receipt, :precision =>15, :scale=>2, :default=>0
      
      t.string :demander_key
      t.references :organisation

      t.timestamps
    end
  end
end
