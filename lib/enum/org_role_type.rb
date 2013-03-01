#encoding=utf-8
require_relative 'enum'

class OrgRoleType
  include Enum
  OrgRoleType.define :DnReciver,100,"运单接收员"
  OrgRoleType.define :DnInspector,200,"运单质检员"
  OrgRoleType.define :DnInstorer,300,"运单入库员"
  OrgRoleType.define :DemandViewer,400,"需求查看员"
  OrgRoleType.define :DemandMaker,500,"运单制作员"
end
