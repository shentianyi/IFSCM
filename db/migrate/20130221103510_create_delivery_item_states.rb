class CreateDeliveryItemStates < ActiveRecord::Migration
  def change
    create_table :delivery_item_states do |t|
      t.string :state
      t.string :desc
      
      t.references :delivery_item

      t.timestamps
    end
    add_index :delivery_item_states, :delivery_item_id
  end
end
