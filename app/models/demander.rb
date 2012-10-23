#coding:utf-8
require 'digest/md5'

class Demander
  attr_accessor :key,:clientId,:clientNr,
  :supplierId,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,:rpartNr,
  :type,:amount,:date,:filedate,:md5key
  
  # def initialize( key, hash )
    # # $redis.hmset( key, *hash.to_a.flatten )
      # @key = key
      # @client = hash[:client]
  # end
  
  def initialize args={}
    if args.count>0
     args.each do |k,v|
       instance_variable_set "@#{k}",v
      end
    end
  end
  
  def save
      $redis.hmset( @key, "client", @client, "supplier", @supplier, "partNr", @rpartNr, "date", @date, "type", @type )
      $redis.sadd( "#{Rns::C}:#{@client}", @key )
      $redis.sadd( "#{Rns::S}:#{@supplier}", @key )
      $redis.sadd( "#{Rns::RP}:#{@rpartNr}", @key )
      $redis.zadd( Rns::Date, @date.to_i, @key )
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
      resultKey
      
  end
  
  def self.test( hash )
    hash[:sdi]
  end
  
  def validate
    
  end
  
  def gen_md5_key
    @md5key=Digest::MD5.hexdigest(@clientId.to_s+':'+@partNr+':'+@amount.to_s+':'+@type+':'+@filedate+':'+@supplierNr)
  end
  
  def redis_validated
    $redis.exists(@md5key)
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