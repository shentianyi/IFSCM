class ChangePackageInfoToStrategy < ActiveRecord::Migration
  def up
    remove_index :package_infos, :part_rel_id
    rename_table :package_infos, :strategies
    add_column :strategies, :needCheck, :string
    add_index :strategies, :part_rel_id
  end

  def down
    remove_index :strategies, :part_rel_id
    remove_column :strategies, :needCheck
    rename_table :strategies, :package_infos
    add_index :package_infos, :part_rel_id
  end
end
