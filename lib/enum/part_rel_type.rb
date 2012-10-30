#encoding=utf-8
require_relative 'enum'

class PartRelType
  include Enum
  PartRelType.define :Client,100,'clientRel'
  PartRelType.define :Supplier,200,'supplierRel' 
end
