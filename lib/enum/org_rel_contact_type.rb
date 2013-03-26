#encoding: utf-8

require_relative 'enum'

class OrgRelContactType
  include Enum
  OrgRelContactType.define :DContact,100,'deliverycontact'
end
