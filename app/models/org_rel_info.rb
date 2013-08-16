#encoding: utf-8
require 'base_class'

class OrgPrinter<CZ::BaseClass
  attr_accessor :key_id,:template,:moduleName,:type,:updated
 
  def self.get_default_printer key_id,type
    zkey=generate_default_set_key key_id
    return find($redis.zrangebyscore(zkey,type,type)[0])
  end
  
  def add_to_dpriter
    zkey=self.class.generate_default_set_key(self.key_id)
    if $redis.zscore(zkey,self.key).nil?
    $redis.zremrangebyscore(zkey,self.type,self.type) if $redis.zcount(zkey,self.type,self.type)>0
    return $redis.zadd(zkey,self.type,self.key)
    end
    return false
  end

  def del_from_dprinter
    $redis.zrem(self.class.generate_default_set_key(self.key_id),self.key)
  end

  def add_to_printer
    skey=self.class.generate_set_key(self.key_id,self.type)
    $redis.sadd(skey,self.key)
  end

  def del_from_printer
    skey=self.class.generate_set_key(self.key_id,self.type)
    $redis.srem(skey,self.key)
    del_from_dprinter
  end

  def destroy
    super
    del_from_printer
  end

  def self.all key_id,type
    skey=generate_set_key key_id,type
    printers=[]
    ($redis.smembers skey).each do |key|
      printers<<find(key)
    end
    return printers
  end
  
  def self.printer_list
    [OrgRelPrinterType::DNPrecheckPrinter]
  end
  
  def self.printer_list_options
    list=[]
    printer_list.each do |p|
      list<<[OrgRelPrinterType.get_desc_by_value(p),p]
    end
    list
  end
  
  private

  def self.generate_default_set_key key_id
    "org:#{key_id}:default:printer:zset"
  end

  def self.generate_set_key key_id,type
    "org:#{key_id}:type:#{type}:printer:set"
  end
end

class OrgRelPrinter<OrgPrinter
  CLIENT_PACK_TEMPLATE= [OrgRelPrinterType::DPackPrinter,OrgRelPrinterType::DPackPrinterAFour]
  
  def self.printer_list
    [OrgRelPrinterType::DNPrinter,OrgRelPrinterType::DPackPrinter,OrgRelPrinterType::DPackPrinterAFour,OrgRelPrinterType::DPackListPrinter,OrgRelPrinterType::DNCheckListPrinter,OrgRelPrinterType::DNInStoreListPrinter]
  end
  private

  def self.generate_default_set_key key_id
    "orgrel:#{key_id}:default:printer:zset"
  end

  def self.generate_set_key key_id,type
    "orgrel:#{key_id}:type:#{type}:printer:set"
  end
end

class OrgRelContactBase<CZ::BaseClass
  attr_accessor :key_id,:type
  def self.find_by_key_id key_id
    zkey=g_or_contact_zset_key key_id
    type=class_type_converter(self.name)
    return find($redis.zrangebyscore(zkey,type,type)[0])
  end

  def add_to_contact
    zkey=OrgRelContactBase.g_or_contact_zset_key(self.key_id)
    if $redis.zscore(zkey,self.key).nil?
    #$redis.zremrangebyscore(zkey,self.type,self.type) if $redis.zcount(zkey,self.type,self.type)>0
    return $redis.zadd(zkey,self.type,self.key)
    end
    return false
  end

  def self.all key_id
    cons=nil
    zkey=g_or_contact_zset_key key_id
    type=class_type_converter(self.name)
    if (keys=$redis.zrangebyscore(zkey,type,type)).count>0
      cons=[]
      keys.each do |k|
        cons<<find(k)
      end
    end
    return cons
  end

  def del_from_contact
    zkey=OrgRelContactBase.g_or_contact_zset_key(self.key_id)
    $redis.zrem(zkey,self.key)
  end

  def destroy
    super
    del_from_contact
  end

  def self.class_type_converter className
    type=case className
    when  "DnContact"
      OrgRelContactType::DContact
    end
    return type
  end

  def self.class_name_converter type
    className=case type
    when OrgRelContactType::DContact
      "DnContact"
    end
    return className
  end
  private

  def self.g_or_contact_zset_key key_id
    "orgrel:#{key_id}:contact:zset"
  end

end

class DnContact<OrgRelContactBase
  attr_accessor :recer_name,:recer_contact,:sender_name,:sender_contact,:rece_address,:send_address
end

