#encoding:utf-8
module LeoniPlymouthPDPack
  @@label_keys=["SupplierNr","CPartNr","Description","Quantity","DnPackNr","Destination"]

  def self.gen_data dn,orl,diKeys=nil
    return gen_di_label dn,orl,diKeys
  end

  private

  def self.gen_di_label dn,orl,diKeys
    dataset=[]
    items=DeliveryBll.get_dn_list dn.key,true,diKeys
    if items and items.count>0
      items.each do |item|
        record=gen_label(item,orl)
        dataset<<record
      end
    end
    return dataset
  end

  def self.gen_label pack,orl
    record=[]
    data={}
    data[:SupplierNr]= orl.supplierNr
    data[:Destination]="WE87"
    # if pack.respond_to?(:cpartNr)
      data[:Quantity]= FormatHelper.string_to_int(pack.perPackAmount.to_s)
      data[:CPartNr]=pack.cpartNr
      pinfo=PartRelInfo.find(pack.part_rel_id)
      data[:Description]="#{pinfo.spartDesc}/#{pack.spartNr}"
      # data[:Description]="pack.spartNr"
    # else
      # data[:Quantity]= FormatHelper.string_to_int(pack.delivery_package.perPackAmount.to_s)
      # data[:CPartNr]=pack.delivery_package.cpartNr
      # data[:Description]=pack.delivery_package.spartNr
    # end

    # pl=PartRelInfo.find(pack.part_rel_id)
    # if pl.position_nr.nil? or pl.position_nr.length==0
    # raise DataMissingError.new,"零件:#{pack.spartNr}未设置零件接收点！请设置好再打印包装箱标签！"
    # else
    # data[:Destination]=pl.position_nr
    # end
    data[:DnPackNr]=pack.key
    @@label_keys.each do |key|
      record<<{:Key=>key,:Value=>data[key.to_sym]}
    end
    return record
  end
end