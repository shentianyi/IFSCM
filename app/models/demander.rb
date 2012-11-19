#coding:utf-8
require 'digest/md5'
require 'base_class'
require 'enum/demander_type'

class Demander<CZ::BaseClass
  attr_accessor :key,:clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate
  NumPer=$DEPSIZE
  
  include FormatHelper
  
  def self.gen_key
        Rns::De+":#{$redis.incr 'demand_index_incr'}"
  end

  
  def self.get_key( id )
    Rns::De+":#{id}"
  end
 
  # ws : add demand history
  def add_to_history history_key
    zset_key=DemandHistory.generate_zset_key @clientId,@supplierId,@relpartId,@type,@date
    $redis.zadd(zset_key,Time.now.to_i,history_key)
  end

  def self.search( hash )
      list = []
      resultKey = "resultKey"
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
          if amount.size==2
            start = amount.first
            amountend = amount.last
          elsif amount.size==1
            start = amountend = amount
          end
          $redis.zinterstore( resultKey, [resultKey, Rns::Amount], :weights=>[0,1] )
          total = $redis.zcount( resultKey, start, amountend )
          $redis.zrangebyscore( resultKey, start, amountend, :withscores=>false, :limit=>[(hash[:page].to_i)*NumPer, NumPer] ).each do |item|
            demands << Demander.find( item )
          end
      else
          start = (hash[:start]&&hash[:start].size>0) ? hash[:start].to_i : -(1/0.0)
          timeend = (hash[:end]&&hash[:end].size>0) ? hash[:end].to_i : (1/0.0)
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
    when DemanderType::Day        then  10
    when DemanderType::Week     then  20
    when DemanderType::Month   then  30
    when DemanderType::Year        then  40
    end
    $redis.zadd( kesKey, score, demandKey)
  end
  
  def self.get_kestrel( orgId, demandType )
    kesKey = gen_kestrel(orgId)
    demands = []
    score = case demandType
    when DemanderType::Day        then  10
    when DemanderType::Week     then  20
    when DemanderType::Month   then  30
    when DemanderType::Year        then  40
    when ''
      $redis.zrange( kesKey, 0, -1).each{|item| demands << Demander.find( item )} and return demands
    end
    $redis.zrangebyscore( kesKey, score, score ).each do |item|
      demands << Demander.find( item )
    end
    return demands
  end
  
  def self.clear_kestrel( orgId, demandType )
    kesKey = gen_kestrel(orgId)
    score = case demandType
    when DemanderType::Day        then  10
    when DemanderType::Week     then  20
    when DemanderType::Month   then  30
    when DemanderType::Year        then  40
    when ''
      return $redis.zremrangebyrank( kesKey, 0, -1)
    end
    return $redis.zremrangebyscore( kesKey, score, score )
  end
  
  def id
    key.delete "#{Rns::De}:"
  end
  
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
          param.each do |c|
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
end