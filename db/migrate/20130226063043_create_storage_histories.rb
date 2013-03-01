class CreateStorageHistories < ActiveRecord::Migration
  def change
    create_table :storage_histories do |t|
      t.integer :opType
      t.decimal :amount, :precision =>15, :scale=>2
      
      t.references :position
      t.references :part

      t.timestamps
    end
  end
end
