#encoding: utf-8

require_relative 'enum'

class OrgRelPrinterType
  include Enum
  OrgRelPrinterType.define :DNPrinter,100,'delivery note printer'
  OrgRelPrinterType.define :DPackPrinter,200,'delivery package printer'
end
