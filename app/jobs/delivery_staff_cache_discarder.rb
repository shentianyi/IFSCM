#encoding: utf-8
class DeliveryStaffCacheDiscarder
  @queue='delivery_queue'
  def self.perform staffId,dnKey
    puts "DeliveryStaffCacheDiscarder:#{staffId}:#{dnKey}"
    DeliveryBll.cancel_staff_dn staffId,dnKey
  end
end