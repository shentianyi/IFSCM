#encoding: utf-8
require 'base_class'

# the score of histoty is Time.to_i
class DemandHistory<CZ::BaseClass
  attr_accessor :demandKey,:rate,:amount,:oldamount,:inputed_at
  def self.get_demander_hitories demander,startIndex,endIndex,score=true
    key=generate_zset_key demander.clientId,demander.supplierId,demander.relpartId,demander.type,demander.date
    dhs=nil
    keys=$redis.zrangebyscore(key,startIndex,endIndex) if score
     keys=$redis.zrange(key,startIndex,endIndex) if !score
    if keys.count>0
      dhs=[]
      keys.each do |k|
        if dh=DemandHistory.find(k)
        dhs<<dh
        end
      end
    end
    return dhs
  end

  def self.get_last_item_key key
    $redis.zrevrange(key,0,0)
  end
  
  def self.get_two_ends(demander)
    key=generate_zset_key demander.clientId,demander.supplierId,demander.relpartId,demander.type,demander.date
    return find($redis.zrange(key,0,0).first), find($redis.zrevrange(key,0,0).first)
  end

  def self.compare_rate(d)
    date=FormatHelper::demand_date_inside(d.date, d.type)
    ckey=generate_zset_key d.clientId,d.supplierId,d.relpartId,d.type,date
    return generate_rate d.amount,ckey
  end

  def self.generate_zset_key clientId,supplierId,relpartId,type,date
    "cId:#{clientId}:spId:#{supplierId}:relpartId:#{relpartId}:type:#{type}:date:#{date}"
  end

  def self.exists clientId,supplierId,relpartId,type,date
    temp = generate_zset_key clientId,supplierId,relpartId,type,date
    if $redis.exists temp
      return DemandHistory.find( $redis.zrevrange(temp,0,0).first ).demandKey
    else
    return false
    end
  end

 def self.delete_zset demander
   key=generate_zset_key demander.clientId,demander.supplierId,demander.relpartId,demander.type,demander.date
   $redis.del key
   puts key
 end
 
  def amount t=nil
    return FormatHelper::get_number @amount,t
  end

  def oldamount t=nil
    return FormatHelper::get_number @oldamount,t
  end
  
  private

  def self.generate_rate amount,zsetkey
    item_key=get_last_item_key zsetkey
    if item_key and item_key.count>0
      dh=DemandHistory.find(item_key[0])
      if dh
      hamount=dh.amount
      if hamount==0 and amount!=0
        return 100,0
      end
      
      if hamount==0 and amount==0
        return 0,0
      end
         
      return ((amount-hamount).to_f)/hamount*100,hamount
      end
    end
    return 0,nil
  end


end