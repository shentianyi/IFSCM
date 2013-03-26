class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :nr
      t.string :name
      
      t.references :organisation

      t.timestamps
    end
    add_index :warehouses, :organisation_id
  end
end
