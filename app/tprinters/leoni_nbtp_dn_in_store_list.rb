#encoding:utf-8
module LeoniNbtpDnInStoreList
  @@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","PerPackNum","PackNr"]

  def self.gen_data dn,orl
    dataset=[]
    items=DeliveryBll.get_dn_check_list_from_mysql({:dnKey=>dn.key,:needCheck=>false})
    if items.length>0
      sendOrg=Organisation.find(dn.organisation_id)
      receOrg=Organisation.find(dn.rece_org_id)
      hrecord=gen_head(dn,sendOrg,receOrg,orl)
      data={}
      items.each do |item|
        record=[]
        data[:PerPackNum]=FormatHelper.string_to_int(item.perPackAmount.to_s)
        data[:PackNr]=item.key
        data[:CPartNr]=item.cpartNr
        @@body_keys.each do |key|
          record<<{:Key=>key,:Value=>data[key.to_sym]}
        end
        dataset<<(record+hrecord)
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
  contact=DnContact.find(dn.destination)
    data[:ReceiverName]=contact.recer_name
    data[:ContactWay]=contact.recer_contact
    data[:DnDestination]=contact.rece_address
    @@head_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end