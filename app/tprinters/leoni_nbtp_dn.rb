#coding:utf-8
module LeoniNbtpDn
  @@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNum","TotalQuantity"]

  def self.gen_data dnKey
    dataset=[]
    dn=DeliveryNote.single_or_default(dnKey)
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)

    if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      dn.items.each do |p|
        record=gen_head(dn,sendOrg,receOrg)
        record=gen_body(p,record)
        dataset<<record
      end
    end
    return dataset
  end

  private

  def self.gen_head dn,sendOrg,receOrg
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
    data[:SupplierNr]=OrganisationRelation.get_parterNr(:oid=>dn.rece_org_id,:pt=>:s,:pid=>dn.organisation_id)
    data[:ClientNr]=OrganisationRelation.get_parterNr(:oid=>dn.organisation_id,:pt=>:c,:pid=>dn.rece_org_id)
    data[:ReceiverName]="原材料仓库-"
    data[:ContactWay]="39939591"
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