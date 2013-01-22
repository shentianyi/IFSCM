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
  end
end
