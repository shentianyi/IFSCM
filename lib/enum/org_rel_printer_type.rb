#encoding: utf-8

require_relative 'enum'
class OrgRelPrinterType
  include Enum
  OrgRelPrinterType.define :DNPrinter,100,'运单'
  OrgRelPrinterType.define :DNPrecheckPrinter,101,'发运库存确认单'
  OrgRelPrinterType.define :DPackPrinter,200,'包装标签-可粘帖'
  OrgRelPrinterType.define :DPackPrinterAFour,201,'包装标签-A4'
  OrgRelPrinterType.define :DPackListPrinter,300,'运单清单'
  OrgRelPrinterType.define :DNCheckListPrinter,400,'质检清单'
  OrgRelPrinterType.define :DNInStoreListPrinter,500,'入库单'
end
