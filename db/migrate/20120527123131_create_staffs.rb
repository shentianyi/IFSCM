class CreateStaffs < ActiveRecord::Migration
  def change
    create_table :staffs do |t|
      t.string :staffNr
      t.string :name
      t.integer :orgId
      t.string :salt
      t.string :pwd
      t.references :organisation
      t.timestamps
    end
    add_index :staffs, :organisation_id
  end
end
