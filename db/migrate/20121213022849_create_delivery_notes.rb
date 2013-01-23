class CreateDeliveryNotes < ActiveRecord::Migration
  def change
    create_table :delivery_notes do |t|
      t.string :key
      t.integer :wayState
      t.integer :rece_org_id
      t.string :destination
      t.integer :state
      t.datetime :sendDate
      t.timestamps

      t.references :staff
      t.references :organisation
    end
    add_index :delivery_notes, :organisation_id
    add_index :delivery_notes,:staff_id
  end
end
