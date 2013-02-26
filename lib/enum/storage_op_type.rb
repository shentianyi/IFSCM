#encoding=utf-8
require_relative 'enum'

class StorageOpType
  include Enum
  StorageOpType.define :In,100,"入库"
  StorageOpType.define :Out,200,"出库"
  StorageOpType.define :Return,300,"退货出库"
end
