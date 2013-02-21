class CleanDeliveryPackage
  def self.clean
    keys=$redis.keys("DeliveryPackage:*")
    keys.each do |key|
      puts "rubish key :#{key}"
      $redis.del key
    end
    
     keys=$redis.keys("P13*")
    keys.each do |key|
      puts "rubish key :#{key}"
      $redis.del key
    end
    
  end
end

CleanDeliveryPackage.clean