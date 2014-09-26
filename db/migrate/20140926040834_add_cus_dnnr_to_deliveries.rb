class AddCusDnnrToDeliveries < ActiveRecord::Migration
  def change
    add_column :delivery_notes, :cusDnnr, :string
  end
end
