#encoding:utf-8
module LeoniNbtpDnCheckList
  # @@body_keys=["CPartNr","PerPackNum","PackNr"]
  def self.gen_data dn,orl
   return LeoniPrinterBase.generate_dn_list(dn,orl,{:dnKey=>dn.key,:needCheck=>true})
  end
end