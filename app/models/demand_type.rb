#coding:utf-8
require 'base_class'

class DemandType<CZ::BaseClass
  attr_accessor :type
  
  def self.gen_set_key
    'demand:type:set'
  end
  
  def self.contains type
    $redis.sismember gen_set_key,type
  end
end