class CleanPartsPartRels
  def self.clean_parts_oart_rels ids
    ids.each do |id|
      key="org:#{id}:parts:zset"
      i=0
      $redis.zrange(key,0,-1).each do |k|
        if k.length-k.strip.length==1          
          puts "#{i+=1}.-#{id}-#{k.length}-#{k.strip.length}"
          score=$redis.zscore(key,k)          
          $redis.zrem(key,k)
          $redis.zadd(key,score,k.strip)
        end
      end
    end
  end
end

CleanPartsPartRels.clean_parts_oart_rels [1,2,3,4,5]
