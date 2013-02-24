#encoding:utf-8
module LeoniNbtpDnCheckList
  @@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","PerPackNum","PackNr"]

  def self.gen_data dn,orl
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)
    hrecord=gen_head(dn,sendOrg,receOrg,orl)
    dataset=(gen_body dn.key,hrecored)
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

  def self.gen_body dnKey,hrecored
    records=[]
    select="delivery_items.*,delivery_packages.perPackAmount,delivery_packages.packAmount,delivery_packages.cpartNr,delivery_packages.spartNr"
    items=DeliveryItem.joins(:delivery_package=>:part_rel,:part_rel=>:strategy,:delivery_package=>:delivery_note).find(:all,:select=>select,
    :conditions=>{"strategies.needCheck"=>true,"delivery_notes.key"=>dnKey})
    items.each do |item|
      record=[]
      data[:PerPackNum]=item.perPackAmount
      data[:PackNr]=item.key
      data[:CPartNr]=item.cpartNr
      @@body_keys.each do |key|
        record<<{:Key=>key,:Value=>data[key.to_sym]}
      end
      records<<(record+hrecord)
    end
    return records
  end
end