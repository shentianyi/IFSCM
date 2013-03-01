#encoding: utf-8
class DeliveryItemInspector

  @queue='delivery_client_queue'
  def self.perform type,ids,dn_id,attrs
    begin
      puts "DeliveryItemInspector:#{ids}--#{attrs}"
      DeliveryBll.delivery_item_inspect(type,ids,dn_id,attrs)
    rescue Exception=>e
      puts e.message
    end
  end
end