class CreateMParts < ActiveRecord::Migration
  def change
    create_table :m_parts do |t|
      t.string :type
      
      t.string :partNr
      
      t.references :m_organisation_relation
      
      t.timestamps
    end
  end
end
