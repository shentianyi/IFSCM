class CreatePackageInfos < ActiveRecord::Migration
  def change
    create_table :package_infos do |t|
      t.integer :leastAmount
      
      t.references :part_rel

      t.timestamps
    end
    add_index :package_infos, :part_rel_id
  end
end
