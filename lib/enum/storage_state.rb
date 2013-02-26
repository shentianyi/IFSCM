#encoding=utf-8
require_relative 'enum'

class StorageState
  include Enum
  StorageState.define :In,100,"在库"
  StorageState.define :Out,200,"已出库"
end
