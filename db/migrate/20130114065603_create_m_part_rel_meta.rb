class CreateMPartRelMeta < ActiveRecord::Migration
  def change
    create_table :m_part_rel_meta do |t|
      t.string :saleNo
      t.string :purchaseNo
      
      t.integer :client_part_id
      t.integer :supplier_part_id

      t.timestamps
    end
  end
end
