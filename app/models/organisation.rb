require 'base_class'
class Organisation<CZ::BaseClass
  ## Hash Key Like "organisation:1234567890"  ,    id must be numeric
  attr_accessor :name, :description, :address, :tel, :website
  attr_reader :key
  
  def self.get_key( id )
    Rns::Org+":#{id}"
  end
  
  def self.find_by_id( id )
    find( get_key( id ) )
  end
  
  def self.option_list
    $redis.keys( Rns::Org+":*" ).collect { |p| [ $redis.hget(p,"name"), p.delete("#{Rns::Org}:") ] }
  end
  
  def id
    key.delete "#{Rns::Org}:"
  end
  
  def list( cs )
    orgs = []
    $redis.zrange( cs, 0, -1, :withscores=>true ).each do |item|
        arr = [ item[0], Organisation.find_by_id( item[1].to_i ) ]
        orgs << arr
    end
    orgs
  end
  
  #########################################   for   Supplier
  def s_key
    "#{id}:"<<Rns::S
  end
  
  def add_supplier( supplierId, supplierNr )
    key = s_key
    $redis.zadd( key, supplierId, supplierNr )
  end
  
  def search_supplier_byNr( supplierNr )
    key = s_key
    $redis.zscore( key, supplierNr ).to_i
  end
  
  def search_supplier_byId( supplierId )
    key = s_key
    arr = $redis.zrangebyscore( key, supplierId, supplierId, :withscores=>false )
    if arr.size==0
      return nil
    else
      return arr.first
    end
  end
  
  
  #########################################   for   Client
  def c_key
    "#{id}:"<<Rns::C
  end
  
  def add_customer( clientId, clientNr )
    key = c_key
    $redis.zadd( key, clientId, clientNr )
  end
  
  def search_customer_byNr( clientNr )
    key = c_key
    $redis.zscore( key, clientNr ).to_i
  end
  
  def search_customer_byId( clientId )
    key = c_key
    arr = $redis.zrangebyscore( key, clientId, clientId, :withscores=>false )
    if arr.size==0
      return nil
    else
      return arr.first
    end
  end
  
end