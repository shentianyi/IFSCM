# class BuildOrCleanRedisSearchIndex
#   
  # # ws : build or clean part rel meta redis-search index
  # # when part rel meta is saved, but not build rsindex
  # # this funtion can be used
    # def self.build_or_clean_part_rel_meta_by_orgIds cid,sid,build
    # parts=Part.find_all_parts_by_orgId cid
    # if parts
      # i=0
      # parts.each do |p|
        # prm=PartRel.get_partRelMetas_by_partKey(cid,sid,p.key,PartRelType::Client)
        # if prm
          # i+=1
          # puts "#{i}. #{p.partNr}"
          # if build
            # prm.buildRSIndex
          # else
           # prm.cleanRSIndex
          # end
        # end
      # end
    # end
  # end
# end
# 
# BuildOrCleanRedisSearchIndex.build_or_clean_part_rel_meta_by_orgIds 1,2,true