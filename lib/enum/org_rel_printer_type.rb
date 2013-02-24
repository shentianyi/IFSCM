#encoding: utf-8

require_relative 'enum'
class OrgRelPrinterType
  include Enum
  OrgRelPrinterType.define :DNPrinter,100,'运单打印机'
  OrgRelPrinterType.define :DPackPrinter,200,'包装标签打印机'
  OrgRelPrinterType.define :DPackListPrinter,300,'运单清单打印机'
  OrgRelPrinterType.define :DNCheckListPrinter,400,'质检清单打印机'
  OrgRelPrinterType.define :DNInStoreListPrinter,500,'入库单打印机'
end
