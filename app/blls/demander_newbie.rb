#encoding: utf-8
module DemanderNewbie
  
  def send_kestrel( sId, demandKey, demandType )
    kesKey = gen_kestrel(sId)
    score = case demandType
    when 'D'   then  DemanderType::Day
    when 'W'   then  DemanderType::Week
    when 'M'   then  DemanderType::Month
    when 'Y'   then  DemanderType::Year
    when 'T'   then  DemanderType::Plan
    when 'O'   then  DemanderType::Order
    end
    $redis.zadd( kesKey, score, demandKey)
  end

  def get_kestrel( orgId, demandType, page )
    kesKey = gen_kestrel(orgId)
    demands = []
    score = case demandType
    when 'D'   then  DemanderType::Day
    when 'W'   then  DemanderType::Week
    when 'M'   then  DemanderType::Month
    when 'Y'   then  DemanderType::Year
    when 'T'   then  DemanderType::Plan
    when 'O'   then  DemanderType::Order
    when ''
      total = $redis.zcard( kesKey )
      $redis.zrange( kesKey, page.to_i*$DEPSIZE, (page.to_i+1)*$DEPSIZE-1 ).each do |item|
        demands << Demander.rfind( item )
      end
      return demands, total
    end
    total = $redis.zcount( kesKey, score, score )
    $redis.zrangebyscore( kesKey, score, score, :limit=>[(page.to_i)*$DEPSIZE, $DEPSIZE] ).each do |item|
      demands << Demander.rfind( item )
    end
    return demands, total
  end

  def clear_kestrel( orgId )
    kesKey = gen_kestrel(orgId)
    $redis.zrange( kesKey, 0, -1).each {|item| Demander.find_by_key(item).rupdate(:accepted=>true) }
    return $redis.del( kesKey )
  end
  
end