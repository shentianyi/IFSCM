#encoding: utf-8
module WarehouseBll
  
  def self.position_out( posiId, partId, amount )
    msg = ReturnMsg.new(:result=>true)
    if !( posiId.is_a?(Fixnum) and amount.is_a?(Float) )
      msg.result = false ; msg.content = "参数错误！"
    return msg
    end
    if ! posi = Position.find_by_id(posiId)
      msg.result = false ; msg.content = "库位不存在！"
    return msg
    end
    total = posi.stock_by_partId(partId)
    if total < amount
      msg.result = false ; msg.content = "库存量不足！"
    return msg
    end
    leftAmount = amount
    posi.storages.by_partId(partId).each do |stor|
      if stor.stock < leftAmount
        stor.update_attributes(:stock=>0)
        leftAmount -= stor.stock
      else
        stor.update_attributes(:stock=>stor.stock-leftAmount)
        break
      end
    end
    posi.storage_histories.build(:opType=>StorageOpType::Out,:amount=>amount,:part_id=>partId).save
    msg.object = total - amount
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
end