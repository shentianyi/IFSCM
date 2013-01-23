class CreateDemanders < ActiveRecord::Migration
  def change
    create_table :demanders do |t|
      t.string :key
      t.integer :clientId
      t.integer :supplierId
      t.integer :relpartId
      t.string :type
      t.integer :amount
      t.integer :oldamount
      t.datetime :date
      t.integer :rate
      t.timestamps
    end
  end
end
