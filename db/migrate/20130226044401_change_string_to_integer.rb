class ChangeStringToInteger < ActiveRecord::Migration
  def up
    change_column :delivery_notes,:state,:integer,:default=>DeliveryObjState::Normal
  end

  def down
  end
end
