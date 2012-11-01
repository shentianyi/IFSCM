#coding:utf-8
require 'digest/md5'
require 'base_class'

class Demander<CZ::BaseClass
  attr_accessor :key,:clientId,:relpartId,:supplierId, :type,:amount,:date,:rate
  NumPer=5
  
  def self.gen_key
        Rns::De+":#{$redis.incr 'demand_index_incr'}"
  end

  
  def self.get_key( id )
    Rns::De+":#{id}"
  end


  def self.search( hash )
      list = []
      resultKey = "resultKey"
      ###########################  client
      if client = union_params( Rns::C, hash[:clientId] )
      list<<client
      end
      ###########################  supplier
      if supplier = union_params( Rns::S, hash[:supplier] )
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
      $redis.expire( resultKey, 30 )
      
      start = (hash[:start]&&hash[:start].size>0) ? hash[:start].to_i : -(1/0.0)
      timeend = (hash[:end]&&hash[:end].size>0) ? hash[:end].to_i : (1/0.0)
      demands = []
      $redis.zrangebyscore( resultKey, start, timeend, :withscores=>true, :limit=>[(hash[:page].to_i-1)*NumPer, NumPer] ).each do |item|
        arr = [ Demander.find( item[0] ), item[1].to_i ]
        demands << arr
      end
      demands
  end

  
  def id
    key.delete "#{Rns::De}:"
  end
  
  def clientNr
    $redis.hget( Organisation.get_key(clientId), :name)
  end
  
  def supplierNr
    $redis.hget( Organisation.get_key(supplierId), :name)
  end
  
  def save_to_send
      $redis.sadd( "#{Rns::C}:#{clientId}", key )
      $redis.sadd( "#{Rns::S}:#{supplierId}", key )
      $redis.sadd( "#{Rns::RP}:#{relpartId}", key )
      $redis.zadd( Rns::Date, date.to_i, key )
      $redis.sadd( "#{Rns::T}:#{type}", key )
  end


  
private
  def self.union_params( column, param )
      return false unless param
      if param.size>0 && param.is_a?(String)
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
end