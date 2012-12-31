module RestSupplierPartMetaLink
  def self.reset_supplier_part_meta_link cid,sid
    cmetas=PartRelMeta.get_by_orgId cid,sid,PartRelType::Client
    smetas=PartRelMeta.get_by_orgId cid,sid,PartRelType::Supplier
    for i in 0..cmetas.count-1
     #puts "#{i}.KEY:#{cmetas[i].key}:Cc:#{cmetas[i].cpartId}:Cs:#{cmetas[i].spartId}--KEY:#{smetas[i].key}Sc:#{smetas[i].cpartId}:Ss:#{smetas[i].spartId}"
           
     key="clientId:#{cid}:supplierId:#{sid}:relType:#{PartRelType.get_by_value(PartRelType::Supplier)}:relmetazset"
     $redis.zrem key,smetas[i].key
     $redis.zadd key,Part.find(smetas[i].spartId).id,cmetas[i].key
     
      csetKey=PartRelMeta.generate_cs_partRel_meta_set_key cid,sid,cmetas[i].cpartId
      ssetKey=PartRelMeta.generate_cs_partRel_meta_set_key cid,sid,smetas[i].spartId
      # puts $redis.smembers ssetKey
          # puts $redis.smembers csetKey
      $redis.srem(ssetKey,($redis.smembers ssetKey)[0])
      $redis.sadd(ssetKey,$redis.smembers(csetKey)[0])
      
      PartRelMeta.find(smetas[i].key).destroy
    end
  end
end

RestSupplierPartMetaLink.reset_supplier_part_meta_link 1,2
RestSupplierPartMetaLink.reset_supplier_part_meta_link 1,3