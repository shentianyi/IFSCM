class CleanDN
  def self.clean_dn
    keys=$redis.keys("DN*")
    if keys.count>0
      c=0
      keys.each do |key|
        puts "#{(c+=1)}.clean: #{key}"
        if dn=DeliveryNote.find(key)
        if mdn=  MDeliveryNote.find_by_key(key)
          mdn.destroy
        end
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
  end
end

CleanDN.clean_dn