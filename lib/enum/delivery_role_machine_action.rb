#encoding=utf-8
require_relative 'enum'
class DeliveryRoleMachineAction
  include Enum
  DeliveryRoleMachineAction.define :DoSend,99,"运单发送"
  DeliveryRoleMachineAction.define :DoArrive,100,"运单到达"
  DeliveryRoleMachineAction.define :DoReject,200,"运单拒收"
  DeliveryRoleMachineAction.define :DoReceive,300,"运单接收"
  DeliveryRoleMachineAction.define :DoInspect,400,"运单质检"
  DeliveryRoleMachineAction.define :DoStore,500,"运单入库"
  DeliveryRoleMachineAction.define :DoReturn,600,"运单退货"
end
