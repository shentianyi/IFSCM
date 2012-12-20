class DeliveryStaffCacheDiscarder
  @queue='delivery_queue'
  def self.perform staffId,dnKey
    puts "DeliveryStaffCacheDiscarder:#{staffId}:#{dnKey}"
    DeliveryHelper::cancel_staff_dn staffId,dnKey
  end
end