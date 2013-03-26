#encoding: utf-8
class DeliveryItemAccepter

  @queue='delivery_client_queue'
  def self.perform ids,dn_id,type
    begin
      puts "DeliveryItemAccepter:#{ids}--#{type}"
      DeliveryBll.delivery_item_accept(ids,dn_id,type)
    rescue Exception=>e
      puts e.message
    end
  end
end