#encoding=utf-8
require_relative 'enum'

class FileDataType
  include Enum
  FileDataType.define :Demand,100,'demand'
end
