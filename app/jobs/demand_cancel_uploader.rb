class DemandUploadCanceler

  @queue='demand_upload_cancel_queue'
  def self.perform batchId
    m=['normal','error']
    if r=RedisFile.find(batchId)
      # 1. del repeate item keys
      rkeys=r.get_repeat_item_keys
      puts '---------------repeat keys'
      puts rkeys
      if rkeys.count>0
        rkeys.each do |k|
          r.del_repeat_item k
        end
      end

      # 2. del single files
      nkeys,ncount=r.get_normal_item_keys 0,-1
      if ncount>0
        nkeys.each do |k|
          if sf=RedisFile.find(k)
            # 2.1 del normal,error item
            m.each do |i|
              nnkeys,count=sf.send "get_#{i}_item_keys".to_sym,0,-1
              if count>0
                nnkeys.each do |dkey|
                  if d=DemanderTemp.find(dkey)
                    puts '---------------demander temp keys'
                    puts d.key

                    d.destory
                  end
                end
              end
            end
          # del sf
          sf.del_items_link
          # delete the file
          sfpath=File.join($DECSVP,sf.uuidName)
          if File.exists? sfpath 
            File.delete(sfpath)
          end
          
          sf.destory
          end
        end
      end
      puts 'del links'
    r.del_items_link
    puts 'del batch'
    r.destory
    end
  end

end