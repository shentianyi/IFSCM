#encoding: utf-8

require_relative 'enum'

class OrgRelPrinterType
  include Enum
  OrgRelPrinterType.define :DNPrinter,100,'delivery note printer'
  OrgRelPrinterType.define :DPackPrinter,200,'delivery package printer'
  OrgRelPrinterType.define :DPackListPrinter,300,'delivery package list printer'
end
