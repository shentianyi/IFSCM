class CreateMDeliveryItems < ActiveRecord::Migration
  def change
    create_table :m_delivery_items do |t|
      t.string :key
      t.integer :state
      t.integer :amount
      t.string :parentKey
      t.string :saleNo
      t.string :purchaseNo
      t.string :cpartNr
      t.string :spartNr
      t.string :partRelMetaKey
      t.references :m_delivery_note

      t.timestamps
    end
    add_index :m_delivery_items, :m_delivery_note_id
  end
end
