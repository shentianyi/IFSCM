#encoding: utf-8
class DeliveryItemReturner
  @queue='delivery_client_queue'
  def self.perform ids,dn_id
    begin
      puts "DeliveryItemReturner:#{ids}"
      DeliveryBll.delivery_item_return(ids,dn_id)
    rescue Exception=>e
      puts e.message
    end
  end
end