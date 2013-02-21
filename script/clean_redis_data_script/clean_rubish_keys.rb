class CleanRubishKeys
  def self.clean
    keys=$redis.keys("DeliveryItemTemp:*")
    keys.each do |key|
      puts "rubish key :#{key}"
      $redis.del key
    end
  end

  keys=$redis.keys("P13*")
  keys.each do |key|
    puts "rubish package key :#{key}"
    $redis.del key
  end

  keys=$redis.keys("staff:*:deliverynote:cache:zset")
  keys.each do |key|
    puts "rubish staff::deliverynote:cache:zset key :#{key}"
    $redis.del key
  end

end

CleanRubishKeys.clean