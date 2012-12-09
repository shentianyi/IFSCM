#encoding=utf-8
require_relative 'enum'
class DeliveryNoteState
  include Enum
  DeliveryNoteState.define :Intransit,100,"在途"
  DeliveryObjectType.define :Postponed,200,"已推迟"
  DeliveryObjectType.define :Canceled,300,"已取消"
  DeliveryObjectType.define :Received,400,"已接收"
  DeliveryObjectType.define :Rejected,500,"已拒收"
end
