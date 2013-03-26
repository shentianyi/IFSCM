class CreateCostCenters < ActiveRecord::Migration
  def change
    create_table :cost_centers do |t|
      t.string :name
      t.string :desc
      
      t.references :organisation

      t.timestamps
    end
    add_index :cost_centers, :organisation_id
  end
end
