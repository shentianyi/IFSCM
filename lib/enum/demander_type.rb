#encoding=utf-8
require_relative 'enum'

class DemanderType
  include Enum
  DemanderType.define :Day,10,"day"
  DemanderType.define :Week,20,"week"
  DemanderType.define :Month,30,"month"
  DemanderType.define :Year,40,"year"
  DemanderType.define :Plan,50,"Plan"
end
