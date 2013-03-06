#encoding:utf-8
module LeoniNbtpDnList
  @@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNr"]

  def self.gen_data dn,orl
    dataset=[]
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)

    if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      dn.items.each do |p|
        hrecord=gen_head(dn,sendOrg,receOrg,orl)
        if p.items=DeliveryPackage.get_children(p.key,0,-1)[0]
          p.items.each do |i|
            brecord=gen_body(p,i.key)
            dataset<<(hrecord+brecord)
          end 
        end
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

  def self.gen_body pack,pkey
    record=[]
    data={}
    data[:PerPackNum]= FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:PackNr]=pkey
    data[:CPartNr]=pack.cpartNr
    data[:SPartNr]=pack.spartNr
    @@body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end