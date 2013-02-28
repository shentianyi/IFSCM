
partId = Part.find_by_partNr("P00116053").id
(5..8).each do |posi|
  puts "_"*40
  puts "---Position 编号："
  puts "           "+posi.to_s
  msg = WarehouseBll.position_in( posi,9,100,partId,objId=nil)
  puts "           "+msg.result.to_s
  
end
