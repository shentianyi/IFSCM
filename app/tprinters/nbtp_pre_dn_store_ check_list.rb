#encoding:utf-8
module NbtpPreDnStoreCheckList
  def self.gen_data staff_id
    items=DeliveryItemTemp.get_staff_cache(staff_id)[0]
    return LeoniPrinterBase.generate_pre_dn_store_check_list(items)
  end
end