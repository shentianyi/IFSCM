#encoding=utf-8
require_relative 'enum'

class FileDataType
  include Enum
  FileDataType.define :CSVDemand,100,"csv demand"
end
