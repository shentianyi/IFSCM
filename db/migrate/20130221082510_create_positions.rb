class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :nr
      t.integer :capacity
      
      t.references :warehouse

      t.timestamps
    end
    add_index :positions, :warehouse_id
  end
end
