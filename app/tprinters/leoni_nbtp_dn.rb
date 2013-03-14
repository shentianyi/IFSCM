#encoding:utf-8
module LeoniNbtpDn
  @@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNum","TotalQuantity"]

  def self.gen_data dn,orl
    dataset=[]
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)
    
    packs=DeliveryBll.get_dn_packinfos dn.key
    if packs and packs.count>0
      hrecord=gen_head(dn,sendOrg,receOrg,orl)
      packs.each do |p|         
        dataset<<(gen_body(p)+hrecord)
      end
    end
    return dataset
  end

  private

  def self.gen_head dn,sendOrg,receOrg,orl
    record=[]
    data={}
    data[:DnNr]=dn.key
    data[:SendDate]=Time.at(dn.sendDate.to_i).strftime('%Y/%m/%d')
    data[:SupplierOrgName]=sendOrg.name
    data[:SupplierOrgAddress]=sendOrg.address
    data[:ClientOrgName]=receOrg.name
    data[:ClientOrgAddress]=receOrg.address
    ## still no:
    # supplierNr, clientNr , receStaffName, receStaffContact
    data[:SupplierNr]= orl.supplierNr
    data[:ClientNr]=orl.clientNr
    # contact=DnContact.find_by_orid(orl.id)
    contact=DnContact.find(dn.destination)
    data[:ReceiverName]=contact.recer_name
    data[:ContactWay]=contact.recer_contact
    data[:DnDestination]=contact.rece_address
    @@head_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end

  def self.gen_body pack
    record=[]
    data={}
    data[:PerPackNum]= FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:PackNum]=pack.packAmount
    data[:TotalQuantity]=FormatHelper.string_multiply(data[:PerPackNum],pack.packAmount)
    data[:CPartNr]=pack.cpartNr
    data[:SPartNr]=pack.spartNr
    @@body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end