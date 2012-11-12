require 'base_class'
class Organisation<CZ::BaseClass
  ## Hash Key Like "organisation:1234567890"  ,    id must be numeric
  attr_accessor :name, :description, :address, :tel, :website,:abbr,:contact,:email
  attr_reader :key
  
  def self.gen_id
   $redis.incr('org_index_incr')
  end
  
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
    OrgRel.new( cs_key: key, orgrelNr: supplierNr ).save_index
  end
  
  def search_supplier_byNr( supplierNr )
    key = s_key
    $redis.zscore( key, supplierNr ).to_i.to_s
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
  
  def add_client( clientId, clientNr )
    key = c_key
    $redis.zadd( key, clientId, clientNr )
    OrgRel.new( cs_key: key, orgrelNr: clientNr ).save_index
  end
  
  def search_client_byNr( clientNr )
    key = c_key
    $redis.zscore( key, clientNr ).to_i.to_s
  end
  
  def search_client_byId( clientId )
    key = c_key
    arr = $redis.zrangebyscore( key, clientId, clientId, :withscores=>false )
    if arr.size==0
      return nil
    else
      return arr.first
    end
  end
  
  # ws get org id by cNr or sNr
  # if client, get supplier id
  # if supplier, get client id
  def get_parterId_by_parterNr orgOpeType,partnerNr
    orgId=nil
    if orgOpeType==OrgOperateType::Client
       orgId=search_supplier_byNr(partnerNr)
    elsif orgOpeType==OrgOperateType::Supplier
       orgId=search_client_byNr(partnerNr)
    end
    return orgId
  end
end