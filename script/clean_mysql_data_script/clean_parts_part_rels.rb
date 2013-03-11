class CleanPartsPartRels
  def self.clean_parts_oart_rels ids
    ids.each do |id|
      if pr=PartRel.where(:organisation_relation_id=>id).first
        puts "pr:#{pr.id}"
      pr.client_part.destroy
      pr.supplier_part.destroy
      pr.destroy
      end
    end
    $redis.zrange("org:1:parts:zset",0,-1).each do |k|
     puts "#{k.length}-#{k.strip.length}"
     if k.length-k.strip.length==1
       $redis.zrem("org:1:parts:zset",k)
     end
    end
  end
end

CleanPartsPartRels.clean_parts_oart_rels [3,4]
