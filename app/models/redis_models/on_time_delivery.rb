require 'base_class'

class OnTimeDelivery<CZ::BaseClass
  attr_accessor :key, :amount, :part_rel_id
  
  def amount t=nil
    return FormatHelper::get_number @amount,t
  end
  
  # [功能：] 更新实际到货的记录。（cf 是据测值，otd 是实际值）
  def update_otd_record
    zsetKey=OnTimeDelivery.generate_partrel_otd_zset_key( self.part_rel_id )
    if !$redis.zscore zsetKey,self.key
      $redis.zadd zsetKey, Time.now.to_i, self.key
    end
  end
  
  # [功能：] 根据时间范围，合并期间的 otd 值。
  def self.get_otd_by_range( iRelpartId, tStart, tEnd )
    zsetKey=OnTimeDelivery.generate_partrel_otd_zset_key( iRelpartId )
    total = 0
    $redis.zrangebyscore( zsetKey, tStart, tEnd ).each do |o|
      next unless otd = OnTimeDelivery.find( o )
      total += otd.amount
    end
    return total
  end
  
  private
  
  def self.generate_partrel_otd_zset_key iPartrelId
    "otd:zset:partrelId:#{iPartrelId}"
  end
  
end
