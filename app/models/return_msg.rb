#encoding: utf-8
class ReturnMsg<BaseMsg
  attr_accessor :result,:object
  def default
    {:result=>false}
  end
end