class CreateDemanders < ActiveRecord::Migration
  def change
    create_table :demanders do |t|
      t.string :key
      t.integer :clientId
      t.integer :supplierId
      t.integer :relpartId
      t.string :type
      t.float :amount
      t.float :oldamount
      t.datetime :date
      t.float :rate
      t.timestamps
    end
  end
end
