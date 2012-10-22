class Demander
  attr_accessor :clientId,:clientNr,:supplierId,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,:type,:date
  
  def initialize( key, hash )
      $redis.hmset( key, *hash.to_a.flatten )
      @client = hash[:client]
      @supplier = hash[:supplier]
      @part = hash[:partNr]
      @date = hash[:date]
      @type = hash[:type]
      $redis.sadd( "#{Rns::C}:#{@client}", key )
      $redis.sadd( "#{Rns::S}:#{@supplier}", key )
      $redis.sadd( "part:#{@part}", key )
      $redis.zadd( "date", @date, key )
      $redis.sadd( "type:#{@type}", key )
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
      client = union_params( hash[:client], Rns::C )
      list<<client
      ###########################  supplier
      supplier = union_params( hash[:supplier], Rns::S )
      list<<supplier
      ###########################  part
      part = union_params( hash[:partNr], Rns::C )
      list<<part
      
      $redis.zinterstore( resultKey, list )
      $redis.expire( resultKey, 30 )
      resultKey
      
  end
  
  def self.test( hash )
    hash[:sdi]
  end
  
  def self.generate_by_files(*args)
    
  end
  
private
  def union_params( param, column )
      if param.is_a?(String)
          key = "#{column}:#{param}"
      elsif param.is_a?(Array)
          param.each do |c|
            c.insert( 0, "#{column}:" )
          end
          key = column
          $redis.zunionstore( key, param )
      else
        raise "wrong Type of arguments"
      end
      key
  end
end