#encoding:utf-8
module LeoniNbtpDnInStoreList
  # @@body_keys=["CPartNr","PerPackNum","PackNr"]
  def self.gen_data dn,orl
    return LeoniPrinterBase.generate_dn_list(dn,orl,{:dnKey=>dn.key,:needCheck=>false})
  end
end