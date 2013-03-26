class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.decimal :stock
      
      t.references :position
      t.references :part

      t.timestamps
    end
    add_index :storages, :position_id
    add_index :storages, :part_id
  end
end
