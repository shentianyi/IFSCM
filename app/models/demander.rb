#coding:utf-8
require 'digest/md5'
require 'base_class'

class Demander<CZ::BaseClass
  attr_accessor :key,:clientId,:clientNr,:relpartId,
  :supplierId,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,
  :type,:amount,:date,:filedate,:vali,:rate,:lineNo,:uuid,:msg
 
  
  def self.gen_index
    $redis.incr 'demand:index:incr'
  end
  
  def save
      $redis.hmset( @key, "clientId", @clientId, "supplierId", @supplierId, "relpartId", @relpartId, "date", @date, "type", @type )
      $redis.sadd( "#{Rns::C}:#{@clientId}", @key )
      $redis.sadd( "#{Rns::S}:#{@supplierId}", @key )
      $redis.sadd( "#{Rns::RP}:#{@relpartId}", @key )
      $redis.zadd( Rns::Date, @date.to_i, @key )
      $redis.sadd( "#{Rns::T}:#{@type}", @key )
  end
  
  def self.get_key( id )
    Rns::De+":#{id}"
  end
  
  # ws rewrite ding's method
  def self.find( key )
    $redis.hgetall key
    # hash = $redis.hgetall( key )
    # demander = Demander.new
    # demander.key = key
    # demander.clientId = hash["clientId"]
    # demander.supplierId = hash["supplierId"]
    # demander.relpartId = hash["relpartId"]
    # demander.date = hash["date"]
    # demander.type = hash["type"]
    # demander
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
  
  #
  
  # ws: save demand temp in redis
  def save_temp_in_redis uuid,msgs
    @uuid=uuid
    $redis.hmset(uuid,'uuid',@uuid,'clientId',@clientId,'supplierNr',@supplierNr,'cpartNr',@cpartNr,'lineNo',@lineNo,
        'cpartId',@cpartId,'amount',@amount,'type',@type,'filedate',@filedate,'date',@date,'vali',@vali)
    if !@vali
      $redis.hset uuid,'msg',msgs.to_json
    else
      #caluate rate
      h=DemandHistory.new(:clientId=>@clientId,:supplierId=>@supplierId,:cpartId=>@cpartId,:type=>@type,:date=>@date,:amount=>@amount)
      @rate=h.calculate_rate
      $redis.hset uuid,'rate',@rate
    end
  end
   
  
  def gen_md5_repeat_key
    Digest::MD5.hexdigest(@clientId.to_s+':'+@cpartNr+':'+@type+':'+(@date.nil?? '' : @date)+':'+@supplierNr)
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