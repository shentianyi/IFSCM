module LeoniNbtpDpack
  @@label_keys=["SupplierNr","CPartNr","Description","Quantity","SendDate","DnPackNr","Destination"]

  def self.gen_data dn,orl
    dataset=[]
    if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      dn.items.each do |p|
        if p.items=DeliveryPackage.get_children(p.key,0,-1)[0]
          p.items.each do |i|
            record=gen_label(p,i.key,dn.sendDate,orl)
            dataset<<record
          end
        end
      end
    end
    return dataset
  end

  private

  def self.gen_label pack,packNr,sendDate,orl
    record=[]
    data={}
    data[:SupplierNr]= orl.supplierNr
    data[:CPartNr]=pack.cpartNr
    data[:Description]=pack.spartNr
    data[:SendDate]=sendDate
    data[:Quantity]=FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:Destination]="WE87"
    data[:DnPackNr]=packNr
    @@label_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end