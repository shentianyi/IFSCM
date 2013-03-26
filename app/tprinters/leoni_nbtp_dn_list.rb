#encoding:utf-8
module LeoniNbtpDnList
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNr"]

  def self.gen_data dn,orl
    dataset=[]
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)
    items=DeliveryBll.get_dn_list dn.key
    if items and items.count>0
      hrecord=LeoniPrinterBase.generate_dn_head(dn,sendOrg,receOrg,orl)
      items.each do |item|
        brecord=gen_body(item)
        dataset<<(hrecord+brecord)
      end
    end
    return dataset
  end

  private
  def self.gen_body pack
    record=[]
    data={}
    data[:PackNr]=pack.key
    data[:PerPackNum]= FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:CPartNr]=pack.cpartNr
    data[:SPartNr]=pack.spartNr
    @@body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end