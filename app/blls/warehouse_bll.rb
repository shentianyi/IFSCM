#encoding: utf-8
module WarehouseBll
  
  def self.position_out( posiId, partNr, amount )
    msg = ReturnMsg.new(:result=>true)
    if !( posiId.is_a?(Fixnum) and amount.is_a?(Float) )
      msg.result = false ; msg.content = "参数错误！"
      return msg
    end
    if ! posi = Position.find_by_id(posiId)
      msg.result = false ; msg.content = "库位不存在！"
      return msg
    end
    if posi.stock_by_part(partNr) < amount
      msg.result = false ; msg.content = "库存量不足！"
      return msg
    end
    posi.storages.by_part(partNr).each do |stor|
      if stor.stock < amount
        stor.update_attributes(:stock=>0)
        amount -= stor.stock
      else
        stor.update_attributes(:stock=>stor.stock-amount)
      end
    end
    return msg
  end
  
end