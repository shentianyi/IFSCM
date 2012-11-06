require 'base_class'

class BaseMsg<CZ::BaseClass
  attr_accessor :type,:content
  
  def self.gen_incr
     $redis.incr 'msg:index:incr'
  end
end
