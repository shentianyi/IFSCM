class CleanDN
  def self.clean_dn
    # redis
    keys=$redis.keys("DN*")
    if keys.count>0
      c=0
      keys.each do |key|
        puts "#{(c+=1)}.clean dn: #{key}"
        if dn=DeliveryNote.single_or_default(key)
          if  dn.items=DeliveryNote.get_children(dn.key,0,-1)
            dn.items=dn.items[0]
            dn.items.each do |i|
              cc=0
              if result=DeliveryPackage.get_children(i.key,0,-1)
                i.items=result[0]
                i.items.each do |ii|
                  puts "#{(cc+=1)}.clean pack item key:#{ii.key}"
                  ii.remove_from_parent
                  ii.rdestroy
                end
              end
              puts "pack key:#{i.key}"
              i.remove_from_parent
              i.rdestroy
            end
          dn.rdestroy
          end
        end
        $redis.del key
      end
    end

    keys=$redis.keys("P13*")
    keys.each do |key|
      puts "rubish package key :#{key}"
      $redis.del key
    end

    # mysql
    c=0
    DeliveryNote.all.each do |mdn|
      puts "#{(c+=1)}.clean: #{mdn.id}-#{mdn.key}"
      mdn.delete_from_staff_cache
      roles=OrgRoleType.all.collect.collect{|r| r.value}
      roles.each do |role|
       mdn.remove_from_org_role(mdn.rece_org_id,role)
      end     
      mdn.destroy
    end
  end
end

CleanDN.clean_dn