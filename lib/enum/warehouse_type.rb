#encoding=utf-8
require_relative 'enum'

class WarehouseType
  include Enum
  WarehouseType.define :Normal,100,"normal"
  WarehouseType.define :Tippoint,200,"warehouse for tipping"
end
