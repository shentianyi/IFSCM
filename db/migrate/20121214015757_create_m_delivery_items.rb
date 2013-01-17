class CreateMDeliveryItems < ActiveRecord::Migration
  def change
    create_table :m_delivery_items do |t|
      t.string :key
      t.integer :state
      t.string :parentKey
      t.references :m_delivery_package
      t.timestamps
    end
    add_index :m_delivery_items, :m_delivery_package_id
  end
end
