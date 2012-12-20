#encoding=utf-8
require_relative 'enum'

class DeliveryObjType
  include Enum
  DeliveryObjType.define :Note,100,"运单"
  DeliveryObjType.define :Package,200,"包装箱"
  DeliveryObjType.define :Item,300,"运单项"
end
