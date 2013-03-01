class RenamePartRelIdAndAddIndexToDeliveryPackage < ActiveRecord::Migration
  def change
     rename_column :delivery_packages, :partRelId, :part_rel_id
     add_index :delivery_packages, [:part_rel_id], :name => "index_delivery_packages_on_part_rel_id"
  end
end
