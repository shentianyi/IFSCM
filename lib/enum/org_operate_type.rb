#encoding=utf-8
require_relative 'enum'

class OrgOperateType
  include Enum
  OrgOperateType.define :Client,100,'client'
  OrgOperateType.define :Supplier,200,'supplier'
end
