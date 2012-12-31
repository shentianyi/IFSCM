# (29..70).each do |num|
  # key="Demander:"+num.to_s
  # puts "Add:    "+key
  # $redis.zadd("date",0,key)
  # $redis.hset(key,"date","2012/12/"+(num%30==0?1:num%30).to_s) 
  # printf "      "
  # puts  $redis.hget(key,"date")
# end



(29..70).each do |num|
  key="Demander:"+num.to_s
  date=$redis.hget(key,"date")
  puts date
  $redis.zadd( "date", Time.parse(date).to_i, key )
end


# puts $redis.zrange("date",0,-1,:withscores=>true)
