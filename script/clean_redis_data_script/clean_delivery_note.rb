class CleanDN
  def self.clean_dn
    # redis
    keys=$redis.keys("DN*")
    if keys.count>0
      c=0
      keys.each do |key|
        puts "#{(c+=1)}.clean dn: #{key}"
        if dn=DeliveryNote.find(key)
          if  dn.items=DeliveryBase.get_children(dn.key,0,-1)[0]
            dn.items.each do |i|
              if result=DeliveryBase.get_children(i.key,0,-1)
                i.items=result[0]
                i.items.each do |ii|
                  puts "pack item key:#{ii.key}"
                  ii.remove_from_parent
                  ii.destroy
                end
              end
              puts "pack key:#{i.key}"
              i.remove_from_parent
              i.destroy
            end
          dn.destroy
          end
        end
      end
    end

    keys=$redis.keys("P2013*")
    keys.each do |key|
      puts "rubish key :#{key}"
      $redis.del key
    end

    # mysql
    c=0
    MDeliveryNote.all.each do |mdn|
      puts "#{(c+=1)}.clean: #{mdn.key}"
      mdn.destroy
    end
  end
end

CleanDN.clean_dn