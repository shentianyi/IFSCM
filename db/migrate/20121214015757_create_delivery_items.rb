class CreateDeliveryItems < ActiveRecord::Migration
  def change
    create_table :delivery_items do |t|
      t.string :key
      t.integer :state
      t.string :parentKey
      t.references :delivery_package
      t.timestamps
    end
    add_index :delivery_items, :delivery_package_id
  end
end
