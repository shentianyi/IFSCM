class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.string :partNr

      t.references :organisation

      t.timestamps
    end

    add_index :parts, :organisation_id
  end
end
