class CreateDeliveryPackages < ActiveRecord::Migration
  def change
    create_table :delivery_packages do |t|
      t.string :key
      t.string :saleNo
      t.string :purchaseNo
      t.string :cpartNr
      t.string :spartNr
      t.string :parentKey
      t.string :partRelMetaKey
      t.integer :packAmount
      t.float :perPackAmount
      t.references :delivery_note

      t.timestamps
    end
    add_index :delivery_packages, :delivery_note_id
  end
end
