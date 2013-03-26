#encoding=utf-8
require_relative 'enum'

class DeliveryObjInspect
  include Enum
  DeliveryObjInspect.define :ExemInspect,100,"免检"
  DeliveryObjInspect.define :SamInspect,200,"抽检"
  DeliveryObjInspect.define :FullInspect,300,"全检"
end
