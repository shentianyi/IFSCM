class ChangeStateFromDeliveryNoteAndDeliveryItem < ActiveRecord::Migration
  def change
    change_column :delivery_notes,:state,:integer,:default=>DeliveryObjState::Normal  
    change_column :delivery_items,:state,:integer,:default=>DeliveryObjState::Normal  
  end
end
