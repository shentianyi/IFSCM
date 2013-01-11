class DeliveryNoteMysqlRecorder
  @queue='delivery_queue'
  def self.perform dnKey
    puts "DeliveryNoteMysqlRecorder:#{dnKey}"
    DeliveryHelper::record_dn_into_mysql dnKey
  end
end