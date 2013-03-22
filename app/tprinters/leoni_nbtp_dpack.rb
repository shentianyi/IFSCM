#encoding:utf-8
module LeoniNbtpDpack
  @@label_keys=["SupplierNr","CPartNr","Description","Quantity","DnPackNr","Destination"]

  def self.gen_data dn,orl,diKeys=nil
    dataset=[]
    items=DeliveryBll.get_dn_list dn.key,true,diKeys
    if items and items.count>0
      items.each do |item|
        record=LeoniPrinterBase.generate_pack_body(item,orl)
        dataset<<record
      end
    end
    return dataset
  end
end