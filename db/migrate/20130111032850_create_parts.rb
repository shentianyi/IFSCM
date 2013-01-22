class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :partNr
      
      t.references :organisation
      
      t.timestamps
    end
  end
end
