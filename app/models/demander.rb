class Demander
  
  def initialize( key="new", hash={:new=>"new"} )
      $redis.hmset( key, *hash.to_a.flatten )
      @client = hash[:client]
      @supplier = hash[:supplier]
      @part = hash[:partNr]
      @date = hash[:date]
      @type = hash[:type]
      $redis.sadd( "#{Rns::C}:#{@client}", key )
      $redis.sadd( "#{Rns::S}:#{@supplier}", key )
      $redis.sadd( "#{Rns::RP}:#{@part}", key )
      $redis.zadd( Rns::Date, @date, key )
      $redis.sadd( "#{Rns::T}:#{@type}", key )
  end
  
  def self.get_key( id )
    Rns::De+":#{id}"
  end
  
  
  def self.find( key )
    $redis.hgetall( key )
  end
  
  def search( hash )
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
      # if relpart = union_params( hash[:partNr], Rns::RP )
      # list<<relpart
      # end
      ###########################  type
      if type = union_params( hash[:type], Rns::T )
      # list<<type
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
  
private
  def union_params( param, column )
      if param.is_a?(String)
          key = "#{column}:#{param}"
                puts "_"*200
      puts type
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