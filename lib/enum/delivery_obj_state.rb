#encoding=utf-8
require_relative 'enum'

class DeliveryObjState
  include Enum
  DeliveryObjState.define :Normal,100,"正常"
  DeliveryObjState.define :Abnormal,200,"异常"
end
