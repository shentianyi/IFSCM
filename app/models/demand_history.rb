require 'base_class'

# the score of histoty is Time.to_i
class DemandHistory<CZ::BaseClass
  attr_accessor :key,:clientId,:supplierId,:relPartId,:type,:date,:rate,:amount,:oldamount
  
  # def gen_set_key
    # DemandHistory.generate_zset_key @clientId,@supplierId,@relPartId,@type,@date
  # end

  # def gen_rate
    # @rate,@oldamount= DemandHistory.generate_rate(@amount,@key)
  # end
  
  def add_to_history
    zset_key=DemandHistory.generate_zset_key @clientId,@supplierId,@relPartId,@type,@date
    $redis.zadd(zset_key,Time.now.to_i,@key)
   @rate,@oldamount= DemandHistory.generate_rate(@amount,zset_key)
  end

  def self.get_demander_keys startIndex,endIndex
    $redis.zrange(key,startIndex,endIndex)
  end

  def self.get_last_item_key key
    $redis.zrevrange(key,0,0)
  end

  def self.compare_rate(clientId,supplierId,relpartId,type,date,amount)
    ckey=generate_zset_key clientId,supplierId,relpartId,type,date
    return generate_rate amount,ckey
  end

  private

  def self.generate_zset_key clientId,supplierId,relpartId,type,date
    "cId:#{clientId}:spId:#{supplierId}:relpartId:#{relpartId}:type:#{type}:date:#{date}"
  end


  def self.generate_rate amount,zsetkey
    item_key=get_last_item_key zsetkey
    if item_key and item_key.count>0
      dh=DemandHistory.find(item_key[0])
      if dh
      hamount=dh.amount.to_i
      return ((amount.to_i-hamount).to_f)/hamount*100,hamount
    end
    end
    return 0,0
  end
   
end