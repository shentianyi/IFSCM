class CreatePartRels < ActiveRecord::Migration
  def change
    create_table :part_rels do |t|
      t.string :saleNo
      t.string :purchaseNo
      
      t.integer :client_part_id
      t.integer :supplier_part_id
      t.references :organisation_relation

      t.timestamps
    end
    
        add_index :part_rels, :organisation_relation_id
  end
end
