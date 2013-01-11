class AddSendDateToMDeliveryNote < ActiveRecord::Migration
  def change
    add_column :m_delivery_notes, :sendDate, :datetime
  end
end
