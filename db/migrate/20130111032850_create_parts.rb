class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :type
      
      t.string :partNr
      
      t.references :organisation_relation
      
      t.timestamps
    end
  end
end
