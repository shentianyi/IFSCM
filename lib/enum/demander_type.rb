#encoding=utf-8
require_relative 'enum'

class DemanderType
  include Enum
  DemanderType.define :Day,'D',"day"
  DemanderType.define :Week,'W',"week"
  DemanderType.define :Month,'M',"month"
  DemanderType.define :Year,'Y',"year"
end
