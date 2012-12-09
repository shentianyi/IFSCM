#encoding=utf-8
require_relative 'enum'

class DeliveryObjectType
  include Enum
  DeliveryObjectType.define :DeliveryNote,100,"运单"
  DeliveryObjectType.define :DeliveryPackage,200,"包装箱"
  DeliveryObjectType.define :DeliveryItem,300,"运单项"
end
