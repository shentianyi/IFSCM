#encoding: utf-8
module WarehouseBll
  def self.position_out( posiId, partId, amount, ccName, scrap=nil )
    msg = ReturnMsg.new(:result=>true, :content=>'出库成功。')
    begin
      raise( ArgumentError, "参数错误：出库量无效！" )  unless ( posiId.is_a?(Fixnum) and amount.is_a?(Float) )
      raise( RuntimeError, "库位不存在！" )  unless posi = Position.find_by_id(posiId)
      total = posi.stock_by_partId(partId)
      raise( RuntimeError, "库存量不足！" )  if total < amount
      leftAmount = amount
      posi.storages.by_partId(partId).each do |stor|
        if stor.stock > leftAmount
          stor.update_attributes(:stock=>stor.stock-leftAmount)
        break
        else
          leftAmount -= stor.stock
          stor.update_attributes(:stock=>0)
        stor.destroy
        end
      end
      if scrap.nil?
        posi.storage_histories.build(:opType=>StorageOpType::Out,:amount=>amount,:part_id=>partId, :cost_center_name=>ccName).save
      else
        posi.storage_histories.build(:opType=>StorageOpType::Scrap,:amount=>amount,:part_id=>partId, :cost_center_name=>ccName).save
      end
      msg.object = total - amount
    rescue Exception => e
    msg.result = false ; msg.content = e.to_s
    return msg
    end
    return msg
  end

  def self.position_in(posiNr,wareId,amount,partId,objId=nil)
    msg=ReturnMsg.new
    if posi=Position.where(:nr=>posiNr,:warehouse_id=>wareId).first
      data={:stock=>amount,:part_id=>partId}
      data[:delivery_item_id]=objId if !objId.nil?
      store=posi.storages.build(data)
      if store.save
        posi.storage_histories.build(:opType=>StorageOpType::In,:amount=>amount,:part_id=>partId).save
      msg.result=true
      end
    else
      msg.content="库位：#{posiNr}不存在"
    end
    return msg
  end

  def self.dn_item_in_by_posiId(posi_id,amount,part_id,obj_id=nil)
    Storage.new(:stock=>amount,:part_id=>part_id,:position_id=>posi_id,:delivery_item_id=>obj_id).save
  end
  
  def self.dn_item_move_by_item_id(posiNr,wareId,item_id)   
    msg=ReturnMsg.new
    if posi=Position.where(:nr=>posiNr,:warehouse_id=>wareId).first
       store= Storage.find_by_delivery_item_id(item_id)
       store.update_attributes(:position_id=>posi.id)
       posi.storage_histories.build(:opType=>StorageOpType::In,:amount=>store.stock,:part_id=>store.part_id).save
       msg.result=true
    else
      msg.content="库位：#{posiNr}不存在"
    end
    return msg
  end
end