class CreateDeliveryNotes < ActiveRecord::Migration
  def change
    create_table :delivery_notes do |t|
      t.string :key
      t.integer :wayState
      t.integer :orgId
      t.integer :sender
      t.integer :desiOrgId
      t.string :destination
      t.integer :state 
      t.datetime :sendDate
      t.timestamps
    end
  end
end
