class CleanPartsPartRelsKeys
 def self.clean ids
    ids.each do |id|
      $redis.del "org:#{id}:parts:zset"
      keys=$redis.keys("corg:#{id}:sorg:*:part:*:clientprls:zset")
      keys+=$redis.keys("corg:#{id}:sorg:*:part:*:supplierprls:zset")
      keys.each do |key|
        puts "##{key}"
        $redis.del key
      end
     end
    end
    Part.all.each do |p|
      puts "part id :#{p.id}"
      p.destroy
    end
    PartRel.all.each do |pl|
      puts "part rel id :#{pl.id}"
      pl.destroy
    end
end

CleanPartsPartRelsKeys.clean [1,2,3,4,5]
