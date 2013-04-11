class AddRemarkToDeliveryPackages < ActiveRecord::Migration
  def change
    add_column :delivery_packages, :remark, :string
  end
end
