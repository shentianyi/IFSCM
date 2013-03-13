#encoding: utf-8
class DeliveryItemInspector

  @queue='delivery_client_queue'
  def self.perform type,ids,dn_id,attrs,state
    begin
      puts "DeliveryItemInspector:#{ids}--#{attrs}-#{state}"
      DeliveryBll.delivery_item_inspect(type,ids,dn_id,attrs,state)
    rescue Exception=>e
      puts e.message
    end
  end
end