#encoding=utf-8
require_relative 'enum'
class DeliveryObjWayState
  include Enum
  DeliveryObjWayState.define :Intransit,100,"在途"
  DeliveryObjWayState.define :Postponed,200,"已推迟"
  DeliveryObjWayState.define :Canceled,300,"已取消"
  DeliveryObjWayState.define :Received,400,"已接收"
  DeliveryObjWayState.define :Rejected,500,"已拒收"
  DeliveryObjWayState.define :Returned,600,"已退货"
  DeliveryObjWayState.define :Arrived,700,"已到达"
  DeliveryObjWayState.define :InAccept,800,"接收中"
end
