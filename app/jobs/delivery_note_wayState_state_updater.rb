#encoding: utf-8
class DeliveryNoteWayStateStateUpdater
  @queue='delivery_client_queue'
  def self.perform id
    begin
      puts "DeliveryNoteWayStateStateUpdater:#{id}"
      DeliveryBll.delivery_note_wayState_state_update(id)
    rescue Exception=>e
      puts e.message
    end
  end
end