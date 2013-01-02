#coding:utf-8
require 'base_class'

class Demander<CZ::BaseClass
  attr_accessor :clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate
  NumPer=$DEPSIZE

  # ws : add demand history
  def add_to_history history_key
    zset_key=DemandHistory.generate_zset_key @clientId,@supplierId,@relpartId,@type,@date
    $redis.zadd(zset_key,Time.now.to_i,history_key)
  end

  def self.search( hash )
    list = []
    puts "......#{hash}"
    resultKey = "resultKey_temp_#{$redis.incr('resultKey_temp_')}"
    ###########################  client
    if client = union_params( Rns::C, hash[:clientId] )
    list<<client
    end
    ###########################  supplier
    if supplier = union_params( Rns::S, hash[:supplierId] )
    list<<supplier
    end
    ###########################  part
    if relpart = union_params( Rns::RP, hash[:rpartNr] )
    list<<relpart
    end
    ###########################  type
    if type = union_params( Rns::T, hash[:type] )
    list<<type
    end
    ###########################  date
    list<<Rns::Date
    
    $redis.zinterstore( resultKey, list, :aggregate=>"MAX" )

    demands = []
    amount = hash[:amount]
    if amount&&amount.size>0
      if amount.size==1
      start = amountend = amount
      elsif amount.size==2 && amount.last.size==0
      start = amount.first
      amountend = $Infin
      elsif amount.size==2
      start = amount.first
      amountend = amount.last
      end
      $redis.zinterstore( resultKey, [resultKey, Rns::Amount], :weights=>[0,1] )
      total = $redis.zcount( resultKey, start, amountend )
      $redis.zrangebyscore( resultKey, start, amountend, :withscores=>false, :limit=>[(hash[:page].to_i)*NumPer, NumPer] ).each do |item|
        demands << Demander.find( item )
      end
    else
      start = (hash[:start]&&hash[:start].size>0) ? hash[:start].to_i : -$Infin
      timeend = (hash[:end]&&hash[:end].size>0) ? hash[:end].to_i : $Infin
      total = $redis.zcount( resultKey, start, timeend )
      $redis.zrangebyscore( resultKey, start, timeend, :withscores=>false, :limit=>[(hash[:page].to_i)*NumPer, NumPer] ).each do |item|
        demands << Demander.find( item )
      end
    end

    $redis.expire( resultKey, 30 )
    return demands, total
  end

  def self.send_kestrel( sId, demandKey, demandType )
    kesKey = gen_kestrel(sId)
    score = case demandType
    when 'D'   then  DemanderType::Day
    when 'W'   then  DemanderType::Week
    when 'M'   then  DemanderType::Month
    when 'Y'   then  DemanderType::Year
    when 'T'   then  DemanderType::Plan
    end
    $redis.zadd( kesKey, score, demandKey)
  end

  def self.get_kestrel( orgId, demandType, page )
    kesKey = gen_kestrel(orgId)
    demands = []
    score = case demandType
    when 'D'   then  DemanderType::Day
    when 'W'   then  DemanderType::Week
    when 'M'   then  DemanderType::Month
    when 'Y'   then  DemanderType::Year
    when 'T'   then  DemanderType::Plan
    when ''
      total = $redis.zcard( kesKey )
      $redis.zrange( kesKey, page.to_i*NumPer, (page.to_i+1)*NumPer-1 ).each do |item|
        demands << Demander.find( item )
        $redis.zrem( kesKey, item )
      end
      return demands, total
    end
    total = $redis.zcount( kesKey, score, score )
    $redis.zrangebyscore( kesKey, score, score, :limit=>[(page.to_i)*NumPer, NumPer] ).each do |item|
      demands << Demander.find( item )
      $redis.zrem( kesKey, item )
    end
    return demands, total
  end

  def self.clear_kestrel( orgId )
    kesKey = gen_kestrel(orgId)
    return $redis.del( kesKey )
  end

  # def id
    # key.delete "#{Rns::De}:"
  # end

  def clientNr
    Organisation.find_by_id(supplierId).search_client_byId( clientId )
  end

  def supplierNr
    Organisation.find_by_id(clientId).search_supplier_byId( supplierId )
  end

  def cpartNr
    Part.find(PartRelMeta.find(relpartId).cpartId).partNr
  end

  def spartNr
    Part.find(PartRelMeta.find(relpartId).spartId).partNr
  end

  def save_to_send
    $redis.sadd( "#{Rns::C}:#{clientId}", key )
    $redis.sadd( "#{Rns::S}:#{supplierId}", key )
    $redis.sadd( "#{Rns::RP}:#{relpartId}", key )
    d = FormatHelper::demand_date_to_date( date,type )
    $redis.zadd( Rns::Date, d.to_i, key )
    $redis.zadd( Rns::Amount, amount, key )
    $redis.sadd( "#{Rns::T}:#{type}", key )
  end

  def save_to_send_update
    $redis.zrem( Rns::Amount, key )
    $redis.zadd( Rns::Amount, amount, key )
  end

  # ws
  # [功能：] 添加零件CF记录
  # 参数：
  # - Demander : demand
  # 返回值：
  # - 无
  def update_cf_record
    zsetKey=Demander.generate_org_part_cf_zset_key(self.clientId,self.relpartId,self.supplierId,self.type)
    if !$redis.zscore zsetKey,self.key
      $redis.zadd zsetKey,Time.parse(self.date).strftime('%Y%m%d').to_i,self.key
    end
  end

  def amount t=nil
    return FormatHelper::get_number @amount,t
  end

  def oldamount t=nil
    return FormatHelper::get_number @oldamount,t
  end

  private

  def self.union_params( column, param )
    return false unless param && param.size>0
    if param.is_a?(String)
      key = "#{column}:#{param}"
    elsif param.is_a?(Array)
      key = column
      param.uniq.each do |c|
        c.insert( 0, "#{column}:" )
      end
    $redis.zunionstore( key, param )
    key
    else
    return false
    end
  end

  def self.gen_kestrel( sId )
    "#{sId}:#{Rns::De}:#{Rns::Kes}"
  end

  def self.generate_org_part_cf_zset_key orgId,partrelId,supplierId,type
    "cId:#{orgId}:partrelId:#{partrelId}:spId:#{supplierId}:type:#{type}:cf:zset"
  end

end