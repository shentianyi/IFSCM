#encoding: utf-8
class DeliveryNoteWayStateStateUpdater
  @queue='delivery_client_queue'
  def self.perform id,ids=nil
    begin
      puts "DeliveryNoteWayStateStateUpdater:#{id}-#{ids}"
      DeliveryBll.delivery_note_wayState_state_update(id,ids)
    rescue Exception=>e
      puts e.message
    end
  end
end