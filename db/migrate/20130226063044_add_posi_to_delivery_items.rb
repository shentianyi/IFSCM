class AddPosiToDeliveryItems < ActiveRecord::Migration
  def change
    add_column :delivery_items, :posi, :string
  end
end
