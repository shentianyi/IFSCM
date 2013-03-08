class InitPartRelInfo
 def self.init
   i=0
   PartRel.all.each do |pl|
     puts "#{i+1}.#{pl.id}"
     pinfo=pl.create_part_rel_info
     puts "#{pinfo.cpartNr}-#{pinfo.spartNr}"
     pl.strategy.update_part_rel_info 
   end
 end
end

InitPartRelInfo.init
