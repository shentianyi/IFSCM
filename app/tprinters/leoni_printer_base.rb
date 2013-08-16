#encoding:utf-8
module LeoniPrinterBase
  @@dn_head_keys=["DnNr","SendDate","SupplierOrgName","SupplierOrgAddress","ClientOrgName","ClientOrgAddress","DnDestination",
    "SupplierNr","ClientNr","ReceiverName","ContactWay"]
  @@pack_body_keys=["SupplierNr","CPartNr","Description","Quantity","DnPackNr","Destination"]
  @@dn_check_body_keys=["CPartNr","PerPackNum","PackNr"]
  @@pre_dn_store_check_list_body_keys=["SPartNr","PerPackNum","PackNum","TotalQuantity"]
  def self.generate_dn_head dn,sendOrg,receOrg,orl
    record=[]
    data={}
    data[:DnNr]=dn.key
    data[:SendDate]=Time.at(dn.sendDate.to_i).strftime('%Y/%m/%d')
    data[:SupplierOrgName]=sendOrg.name
    data[:SupplierOrgAddress]=sendOrg.address
    data[:ClientOrgName]=receOrg.name
    data[:ClientOrgAddress]=receOrg.address
    data[:SupplierNr]= orl.supplierNr
    data[:ClientNr]=orl.clientNr
    contact=DnContact.find(dn.destination)
    data[:ReceiverName]=contact.recer_name
    data[:ContactWay]=contact.recer_contact
    data[:DnDestination]=contact.rece_address
    @@dn_head_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end

  def self.generate_pack_body pack,orl,&block
    record=[]
    data={}
    data[:SupplierNr]= orl.supplierNr
    data[:Quantity]= FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:CPartNr]=pack.cpartNr
    pl=PartRelInfo.find(pack.part_rel_id)
    if block
      data[:Description]=yield(pl,pack)
    else
      data[:Description]=pack.spartNr
    end
    if pl.position_nr.nil? or pl.position_nr.length==0
      raise DataMissingError.new,"零件:#{pack.spartNr}未设置零件接收点！请设置好再打印包装箱标签！"
    else
      data[:Destination]= pl.position_nr
    end
    data[:DnPackNr]=pack.key
    @@pack_body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
  
  def self.generate_dn_list dn,orl,condi
    dataset=[]
    items=DeliveryBll.get_dn_check_list_from_mysql(condi)
    if items.length>0
      sendOrg=Organisation.find(dn.organisation_id)
      receOrg=Organisation.find(dn.rece_org_id)
      hrecord=generate_dn_head(dn,sendOrg,receOrg,orl)
      data={}
      items.each do |item|
        record=[]
        data[:PerPackNum]=FormatHelper.string_to_int(item.perPackAmount.to_s)
        data[:PackNr]=item.key
        data[:CPartNr]=item.cpartNr
        @@dn_check_body_keys.each do |key|
          record<<{:Key=>key,:Value=>data[key.to_sym]}
        end
        dataset<<(record+hrecord)
      end
    end
    return dataset
  end
  
  def self.generate_pre_dn_store_check_list items
    dataset=[]
    if items
      data={}
      items.each do |item|
        record=[]
        data[:SPartNr]=item.spartNr
        data[:PerPackNum]=item.packAmount
        data[:PackNum]=item.perPackAmount
        data[:TotalQuantity]=FormatHelper.string_multiply(data[:PerPackNum],data[:PackNum])
        @@pre_dn_store_check_list_body_keys.each do |key|
          record<<{:Key=>key,:Value=>data[key.to_sym]}
        end
        dataset<<record
      end
    end
    return dataset
  end
   
end