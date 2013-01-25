#encoding: utf-8

require_relative 'enum'

class OrgRelPrinterType
  include Enum
  OrgRelPrinterType.define :DNPrinter,100,'print delivery note'
  OrgRelPrinterType.define :DPackPrinter,200,'print delivery package'
end
