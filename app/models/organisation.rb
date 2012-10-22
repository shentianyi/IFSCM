class Organisation
  
  def self.get_key( id )
    Rns::Org+":#{id}"
  end
  
  def self.new( key, hash )
    if $redis.exists( key )
      return false
    else
      $redis.hmset( key, *hash.to_a.flatten )
    end
  end
  
  def self.find( key )
    $redis.hgetall( key )
  end
  
  def self.add_supplier( id, supplierId, supplierNr )
    key = "#{id}:"<<Rns::S
    $redis.zadd( key, supplierId, supplierNr )
  end
  
  def self.add_customer( id, customerId, customerNr )
    key = "#{id}:"<<Rns::C
    $redis.zadd( key, customerId, customerNr )
  end
  
  def self.search_supplier_byNr( id, supplierNr )
    key = "#{id}:"<<Rns::S
    $redis.zscore( key, supplierNr )
  end
  
  def self.search_customer_byNr( id, customerNr )
    key = "#{id}:"<<Rns::C
    $redis.zscore( key, customerNr )
  end
  
  def self.search_supplier_byId( id, supplierId )
    key = "#{id}:"<<Rns::C
    arr = $redis.zrangebyscore( key, supplierId, supplierId, :withscores=>false )
    if arr.size==0
      return nil
    else
      return arr.first
    end
  end
  
  def self.search_customer_byId( id, customerId )
    key = "#{id}:"<<Rns::S
    arr = $redis.zrangebyscore( key, customerId, customerId, :withscores=>false )
    if arr.size==0
      return nil
    else
      return arr.first
    end
  end
  
end