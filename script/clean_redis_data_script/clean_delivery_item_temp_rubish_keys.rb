class CleanDeliveryItemTemp
  def self.clean
    keys=$redis.keys("DeliveryItemTemp:*")
    keys.each do |key|
      puts "rubish key :#{key}"
      $redis.del key
    end
  end
end

CleanDeliveryItemTemp.clean