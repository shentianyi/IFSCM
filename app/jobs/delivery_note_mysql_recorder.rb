#encoding: utf-8
class DeliveryNoteMysqlRecorder
  @queue='delivery_queue'
  def self.perform dnKey
    begin
    puts "DeliveryNoteMysqlRecorder:#{dnKey}"
    DeliveryBll.record_dn_into_mysql dnKey
    rescue Exception=>e
     puts e.message
    end
  end
end