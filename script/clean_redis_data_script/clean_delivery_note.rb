class CleanDN
  def self.clean_dn
    # redis
    keys=$redis.keys("DN*")
    if keys.count>0
      c=0
      keys.each do |key|
        puts "#{(c+=1)}.clean: #{key}"
        if dn=DeliveryNote.find(key)
          dn.get_children 0,-1
          if dn.items
            dn.items.each do |i|
              i.remove_from_parent
              i.destroy
            end
          dn.destroy
          end
        end
      end
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