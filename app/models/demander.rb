#coding:utf-8
require 'digest/md5'
require 'base_class'

class Demander<CZ::BaseClass
  attr_accessor :key,:clientId,:relpartId,:supplierId, :type,:amount,:date,:rate
  
  def self.gen_index
    $redis.incr 'demand:index:incr'
  end

  
  def self.get_key( id )
    Rns::De+":#{id}"
  end


#   
  # def self.find( key )
    # hash = $redis.hgetall( key )
    # demander = Demander.new
    # demander.instance_variable_set "@key", key
    # hash.each do |k,v|
      # demander.instance_variable_set "@#{k}",v
    # end
    # demander
  # end
  

  def self.search( hash )
      list = []
      resultKey = "resultKey"
      ###########################  client
      if client = union_params( hash[:client], Rns::C )
      list<<client
      end
      ###########################  supplier
      if supplier = union_params( hash[:supplier], Rns::S )
      list<<supplier
      end
      ###########################  part
      if relpart = union_params( hash[:rpartNr], Rns::RP )
      list<<relpart
      end
      ###########################  type
      if type = union_params( hash[:type], Rns::T )
      list<<type
      end
      ###########################  date
      list<<Rns::Date
      
      $redis.zinterstore( resultKey, list, :aggregate=>"MAX" )
      $redis.expire( resultKey, 30 )
      
      start = hash[:start].size>0 ? hash[:start].to_i : -(1/0.0)
      timeend = hash[:end].size>0 ? hash[:end].to_i : (1/0.0)
      demands = []
      $redis.zrangebyscore( resultKey, start, timeend, :withscores=>true ).each do |item|
        arr = [ Demander.find( item[0] ), item[1] ]
        demands << arr
      end
      demands
  end

  
  def id
    key.delete "#{Rns::De}:"
  end
  
  def clientNr
    $redis.hget( Organisation.get_key(clientId),"name")
  end
  
  def supplierNr
    $redis.hget( Organisation.get_key(supplierId),"name")
  end
  
  def save_to_send
      $redis.hmset( key, "clientId", clientId, "supplierId", supplierId, "relpartId", relpartId, "date", date, "type", type )
      $redis.sadd( "#{Rns::C}:#{clientId}", key )
      $redis.sadd( "#{Rns::S}:#{supplierId}", key )
      $redis.sadd( "#{Rns::RP}:#{relpartId}", key )
      $redis.zadd( Rns::Date, date.to_i, key )
      $redis.sadd( "#{Rns::T}:#{type}", key )
  end


  
private
  def self.union_params( param, column )
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