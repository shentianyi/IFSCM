#encoding: utf-8
class DeliveryItemAllUpdater

  @queue='delivery_client_queue'
  def self.perform type,ids,attrs
    begin
      puts "DeliveryItemAllUpdater:#{ids}--#{attrs}"
      DeliveryBll.delivery_item_update_all(type,ids,attrs)
    rescue Exception=>e
      puts e.message
    end
  end
end