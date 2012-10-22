class DemandForecast
  
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
      resultKey = nil
      ###########################  client
      client = union_client( hash[:client] )
      list<<client
      ###########################  supplier
      if hash[:supplier].is_a?(String)
        supplier = "#{Rns::S}:#{hash[:supplier]}"
      elsif hash[:supplier].is_a?(Array)
        hash[:supplier].each do |c|
          c.insert( 0, "#{Rns::S}:" )
        end
        supplier = "supplier"
        $redis.zunionstore( supplier, hash[:supplier] )
      else
        raise "wrong Type of arguments"
      end
      list<<supplier
      ###########################  part
      if hash[:client].is_a?(String)
        client = "client:#{hash[:client]}"
      elsif hash[:client].is_a?(Array)
        hash[:client].each do |c|
          c.insert( 0, "client:" )
        end
        client = "client"
        $redis.zunionstore( client, hash[:client] )
      else
        raise "wrong Type of arguments"
      end
      list<<client
      
      $redis.zinterstore( resultKey, list )
      $redis.expire( resultKey, 30 )
      resultKey
      
  end
  
  def self.test( hash )
    hash[:sdi]
  end
  
private
  def union_client( client )
      if client.is_a?(String)
          key = "#{Rns::C}:#{client}"
      elsif client.is_a?(Array)
          client.each do |c|
            c.insert( 0, "#{Rns::C}:" )
          end
          key = "client"
          $redis.zunionstore( key, client )
      else
        raise "wrong Type of arguments"
      end
      key
  end
end