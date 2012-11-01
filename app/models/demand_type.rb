require 'base_class'

class DemandType<CZ::BaseClass
  attr_accessor :type
  
  def self.gen_key
    "demand:type:#{$redis.incr 'demand_type_incr'}"
  end
  
  def self.gen_set_key
    'demand:type:set'
  end
  
  def self.find_by_type type
    $redis.sismember gen_set_key,type
  end
end