#encoding:utf-8
module LeoniNbtpDn
  @@body_keys=["CPartNr","SPartNr","PerPackNum","PackNum","TotalQuantity","OrderNr","Remark"]

  def self.gen_data dn,orl
    dataset=[]
    sendOrg=Organisation.find(dn.organisation_id)
    receOrg=Organisation.find(dn.rece_org_id)
    
    packs=DeliveryBll.get_dn_packinfos dn.key
    if packs and packs.count>0
      hrecord=LeoniPrinterBase.generate_dn_head(dn,sendOrg,receOrg,orl)
      packs.each do |p|         
        dataset<<(gen_body(p)+hrecord)
      end
    end
    return dataset
  end

  private
  def self.gen_body pack
    record=[]
    data={}
    data[:PerPackNum]= FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:PackNum]=pack.packAmount
    data[:TotalQuantity]=FormatHelper.string_multiply(data[:PerPackNum],pack.packAmount)
    data[:CPartNr]=pack.cpartNr
    data[:SPartNr]=pack.spartNr
    data[:OrderNr]=pack.orderNr.nil? ? "":pack.orderNr
    data[:Remark]=pack.remark.nil? ? "":pack.remark
    @@body_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end