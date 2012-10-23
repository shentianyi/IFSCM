class BaseMsg
  attr_accessor :type,:content
  
  def self.gen_index
     $redis.incr 'msg:index:incr'
  end
end