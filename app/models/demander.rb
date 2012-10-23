#coding:utf-8
require 'digest/md5'

class Demander
  attr_accessor :key,:clientId,:clientNr,
  :supplierId,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,
  :type,:amount,:date,:filedate,:md5repeatKey,:vali
  
  def initialize args={}
    if args.count>0
     args.each do |k,v|
       instance_variable_set "@#{k}",v
      end
    end
  end
  
  def self.gen_index
    $redis.incr 'demand:index:incr'
  end
  
  def save
      $redis.hmset( @key, "client", @client, "supplier", @supplier, "partNr", @part, "date", @date, "type", @type )
      $redis.sadd( "#{Rns::C}:#{@client}", @key )
      $redis.sadd( "#{Rns::S}:#{@supplier}", @key )
      $redis.sadd( "#{Rns::RP}:#{@part}", @key )
      $redis.zadd( Rns::Date, @date, @key )
      $redis.sadd( "#{Rns::T}:#{@type}", @key )
  end
  
  def self.get_key( id )
    Rns::De+":#{id}"
  end
  

  def self.find( key )
    $redis.hgetall( key )
  end
  
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
      if relpart = union_params( hash[:partNr], Rns::RP )
      list<<relpart
      end
      ###########################  type
      if type = union_params( hash[:type], Rns::T )
      list<<type
      end
      ###########################  date
      list<<Rns::Date
      
      $redis.zinterstore( resultKey, list )
      $redis.expire( resultKey, 30 )
      resultKey
      
  end
  
  def self.test( hash )
    hash[:sdi]
  end
  
  def save_temp_in_redis uuid,msgs
    $redis.hmset uuid,'clientId',@clientId,'supplierNr',@supplierNr,'cpartNr',@cpartNr,'cpartId',@cpartId,'amount',@amount,'type',@type,'filedate',@filedate,'date',@date,'vali',@vali
    if !@vali
      $redis.hset uuid,'msg',msgs.to_json
    end
  end
   
  
  def gen_md5_repeat_key
    @md5repeatKey=Digest::MD5.hexdigest(@clientId.to_s+':'+@partNr+':'+@type+':'+@date+':'+@supplierNr)
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