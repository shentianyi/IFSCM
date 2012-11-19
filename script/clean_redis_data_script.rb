class CleanRedisData
  def self.clean_deamand_by_org id 
 total=Demander.search({:clientId=>id,:page=>0})[1]
     puts 'total:'+total.to_s
    pages=total/Demander::NumPer+(total%Demander::NumPer==0?0:1)
    puts "pages:#{pages}"
   for i in 0...pages
  demands=Demander.search({:clientId=>id,:page=>i})[0]
  puts "pageIndex:#{i}"
  if !demands.nil?
      demands.each do |d|
     
        if    dhs=DemandHistory.get_demander_hitories(d,0,-1,false)
        dhs.each do |dh|
           dh.destory if dh
        end
        end
        DemandHistory.delete_zset d
          d.destory
      end 
  end
  end
  end
end



CleanRedisData.clean_deamand_by_org 1