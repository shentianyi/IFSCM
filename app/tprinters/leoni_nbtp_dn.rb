#coding:utf-8
module LeoniNbtpDn  
  @@head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNum","TotalQuantity"]

  def self.gen_data dnKey
    dataset=[]
    dn=DeliveryNote.find(dnKey)
    sendOrg=Organisation.find_by_id(dn.orgId)
    receOrg=Organisation.find_by_id(dn.desiOrgId)

    if dn.items=DeliveryBase.get_children(dn.key,0,-1)[0]
      dn.items.each do |p|
        record=gen_head(dn,sendOrg,receOrg)
        record=gen_body(p,dn.wayState,record)
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
    data[:SendDate]=dn.sendDate
    data[:SupplierOrgName]=sendOrg.name
    data[:SupplierOrgAddress]=sendOrg.address
    data[:ClientOrgName]=receOrg.name
    data[:ClientOrgAddress]=receOrg.address
    data[:DnDestination]=dn.destination
    ## still no:
    # supplierNr, clientNr , receStaffName, receStaffContact
    data[:SupplierNr]="0314CN"
    data[:ClientNr]="TECSM1044"
    data[:ReceiverName]="原材料仓库"
    data[:ContactWay]="39939591"
    @@head_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end

  def self.gen_body pack,sent,record
    data={}
    data[:PerPackNum]=pack.perPackAmount
    data[:PackNum]=pack.packAmount
    data[:TotalQuantity]=pack.perPackAmount*pack.packAmount
    if sent
      data[:CPartNr]=pack.cpartNr
      data[:SPartNr]=pack.spartNr
    else
      prm=PartRelMeta.find(pack.partRelMetaKey)
      data[:CPartNr]=Part.find(prm.cpartId).partNr
      data[:SPartNr]=Part.find(prm.spartId).partNr
    end
    @@body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end