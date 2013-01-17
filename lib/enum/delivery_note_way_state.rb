#encoding=utf-8
require_relative 'enum'
class DeliveryNoteWayState
  include Enum
  DeliveryNoteWayState.define :Intransit,100,"在途"
  DeliveryNoteWayState.define :Postponed,200,"已推迟"
  DeliveryNoteWayState.define :Canceled,300,"已取消"
  DeliveryNoteWayState.define :Received,400,"已接收"
  DeliveryNoteWayState.define :Rejected,500,"已拒收"
  DeliveryNoteWayState.define :Returned,600,"已退货"
end
