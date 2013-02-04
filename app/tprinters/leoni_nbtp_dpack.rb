module LeoniNbtpDpack
  @@label_keys=["SupplierNr","CPartNr","Description","Quantity","DnPackNr","Destination"]

  def self.gen_data dn,orl,diKeys=nil
    if diKeys
      return gen_selected_di_label dn,orl,diKeys
    else
      return gen_all_di_label dn,orl
    end

  end

  private

  def self.gen_all_di_label dn,orl
    dataset=[]
    if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      dn.items.each do |p|
        if p.items=DeliveryPackage.get_children(p.key,0,-1)[0]
          p.items.each do |i|
            record=gen_label(p,i.key,orl)
            dataset<<record
          end
        end
      end
    end
    return dataset
  end

  def self.gen_selected_di_label dn,orl,diKeys
    dataset=[]
    diKeys.each do |k|
      if i=DeliveryItem.single_or_default(k)
        p=DeliveryPackage.single_or_default(i.parentKey)
        record=gen_label(p,i.key,orl)
      dataset<<record
      end
    end
    return dataset
  end

  def self.gen_label pack,packNr,orl
    record=[]
    data={}
    data[:SupplierNr]= orl.supplierNr
    data[:CPartNr]=pack.cpartNr
    data[:Description]=pack.spartNr
    # data[:SendDate]=sendDate
    data[:Quantity]=FormatHelper.string_to_int(pack.perPackAmount.to_s)
    data[:Destination]="WE87"
    data[:DnPackNr]=packNr
    @@label_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end