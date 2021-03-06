#encoding:utf-8
module LeoniPlymouthDpack
  def self.gen_data dn,orl,diKeys=nil
#puts '------------server'
    dataset=[]
    items=DeliveryBll.get_dn_list dn.key,true,diKeys
    if items and items.count>0
      items.each do |item|
        block=Proc.new {|pl,pack| "#{pl.spartDesc}/#{pack.spartNr}" }
        record=LeoniPrinterBase.generate_pack_body(item,orl,&block)
        dataset<<record
      end
    end
    return dataset
  end
end
