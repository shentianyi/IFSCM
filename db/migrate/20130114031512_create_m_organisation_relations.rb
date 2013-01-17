class CreateMOrganisationRelations < ActiveRecord::Migration
  def change
    create_table :m_organisation_relations do |t|
      
      t.string :supplierNr
      t.string :clientNr
      
      t.integer :origin_supplier_id
      t.integer :origin_client_id

      t.timestamps
    end
  end
end
