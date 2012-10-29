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
      nkeys=r.get_normal_item_keys 0,-1
      puts '---------------normal keys'
      puts nkeys
      if nkeys.count>0
        nkeys.each do |k|
          if sf=RedisFile.find(k)
            puts sf.oriName
            # 2.1 del normal,error item
            m.each do |i|
              nnkeys=sf.send "get_#{i}_item_keys".to_sym,0,-1
              if nnkeys.count>0
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
          sf.destory
          end
        end
      end
    r.del_items_link
    r.destory
    end
  end

end