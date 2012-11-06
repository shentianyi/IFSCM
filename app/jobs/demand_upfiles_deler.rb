class DemandUpfilesDeler
  @queue='demand_queue'
  def self.perform batchId
    puts "do DemandUpfilesDeler:#{batchId}"
    if r=RedisFile.find(batchId)
      nkeys,ncount=r.get_normal_item_keys 0,-1
      if ncount>0
        nkeys.each do |k|
          if sf=RedisFile.find(k)
            sfpath=File.join($DECSVP,sf.uuidName)
            if File.exists? sfpath
              File.delete(sfpath)
            end
          end
        end
      end
    end
  end
end