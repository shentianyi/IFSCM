#encoding=utf-8
require_relative 'enum'

class DeliveryObjInspectState
  include Enum
  DeliveryObjInspectState.define :Normal,100,"正常"
  DeliveryObjInspectState.define :Deletion,200,"缺失"
  DeliveryObjInspectState.define :Damaged,300,"损坏"
  DeliveryObjInspectState.define :Other,400,"其它"
end
