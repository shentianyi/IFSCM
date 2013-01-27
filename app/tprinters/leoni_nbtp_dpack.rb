module LeoniNbtpDpack
@@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNum","TotalQuantity"]

  def self.gen_data dn,orl
    dataset=[]
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)

    if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      dn.items.each do |p|
        record=gen_head(dn,sendOrg,receOrg,orl)
        record=gen_body(p,record)
        dataset<<record
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
    data[:DnDestination]=dn.destination
    ## still no:
    # supplierNr, clientNr , receStaffName, receStaffContact
    data[:SupplierNr]= orl.supplierNr
    data[:ClientNr]=orl.clientNr
    contact=DnContact.find_by_orid(orl.id)
    data[:ReceiverName]=contact.recer_name
    data[:ContactWay]=contact.recer_contact
    @@head_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end

  def self.gen_body pack,record
    data={}
    data[:PerPackNum]=pack.perPackAmount
    data[:PackNum]=pack.packAmount
    data[:TotalQuantity]=FormatHelper.string_multiply(pack.perPackAmount,pack.packAmount)
    data[:CPartNr]=pack.cpartNr
    data[:SPartNr]=pack.spartNr

    @@body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end