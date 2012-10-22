#encoding=utf-8
require_relative 'enum'

class MsgType
  include Enum
  MsgType.define :OK,100,'ok'
  MsgType.define :Warn,200,'warn'
  MsgType.define :Error,300,'error'
  MsgType.define :Exception,400,'exception'
end
