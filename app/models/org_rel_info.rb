#encoding: utf-8
require 'base_class'

class OrgRelPrinter<CZ::BaseClass
  attr_accessor :org_rel_id,:template,:moduleName,:type
  
  def self.get_default_printer orid,type
    zkey=g_or_dprinter_zset_key orid
    return find($redis.zrangebyscore(zkey,type,type)[0])
  end

  def add_to_dpriter
    zkey=OrgRelPrinter.g_or_dprinter_zset_key(self.org_rel_id)
    if $redis.zscore(zkey,self.key).nil?
     $redis.remrangebyscore(zkey,self.type,self.type) if $redis.zcount(zkey,self.type,self.type)>0
    return $redis.zadd(zkey,self.type,self.key)
    end
    return false
  end

  def del_from_dprinter
    $redis.zrem(OrgRelPrinter.g_or_dprinter_zset_key(self.org_rel_id),self.key)
  end

  def add_to_printer
    skey=OrgRelPrinter.g_or_printer_set_key(self.org_rel_id,self.type)
    $redis.sadd(skey,self.key)
  end

  def del_from_printer
    skey=OrgRelPrinter.g_or_printer_set_key(self.org_rel_id,self.type)
    $redis.srem(skey,self.key)
    del_from_dprinter
  end

  def destroy
    super
    del_from_printer
  end
  private

  def self.g_or_dprinter_zset_key orid
    "orgrel:#{orid}:default:printer:zset"
  end

  def self.g_or_printer_set_key orid,type
    "orgrel:#{orid}:type:#{type}:printer:set"
  end
end

class OrgRelContactBase<CZ::BaseClass
  attr_accessor :org_rel_id,:type
    
  def self.find_by_orid orid
    zkey=g_or_contact_zset_key orid
     type=class_type_converter(self.name)
    return find($redis.zrangebyscore(zkey,type,type)[0])
  end
  
  def add_to_contact
    zkey=OrgRelContactBase.g_or_contact_zset_key(self.org_rel_id)
    if $redis.zscore(zkey,self.key).nil?
     $redis.remrangebyscore(zkey,self.type,self.type) if $redis.zcount(zkey,self.type,self.type)>0
     return $redis.zadd(zkey,self.type,self.key)
    end
    return false
  end
  
  
  def del_from_contact
    skey=OrgRelPrinter.g_or_printer_set_key(self.org_rel_id,self.type)
    $redis.srem(skey,self.key)
  end

  def destroy
    super
    del_from_contact
  end

  private
  def self.g_or_contact_zset_key orid
    "orgrel:#{orid}:contact:zset"
  end
  
  def self.class_type_converter className
    type=case className
    when  "DnContact"
     OrgRelContactType::DContact
    end
    return type
  end
end

class DnContact<OrgRelContactBase
  attr_accessor :recer_name,:recer_contact,:sender_name,:sender_contact,:rece_address,:send_address
end


