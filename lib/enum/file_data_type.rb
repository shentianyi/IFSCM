#encoding=utf-8
require_relative 'enum'

class FileDataType
  include Enum
  FileDataType.define :CSVDemand,100,"csv demand"
  FileDataType.define :CSVPartRel,200,"csv PartRel"
  FileDataType.define :CSVRelpartPackage,300,"csv Relpart Package"
  FileDataType.define :CSVRelpartCheck,400,"csv Relpart Check"
end
