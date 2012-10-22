module Enum
  def initialize(key,value,desc)
    @key=key
    @value=value
    @desc=desc
  end
  
  def key
    @key
  end
  
  def value
   @value
  end
  
  def desc
    @desc
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def define(key,value,desc)
      @hash||={}
      @hash[key]=self.new(key,value,desc)
    end
    
    def const_missing(key)
      @hash[key].value
    end
     
     
     def get(key)
       @hash[key]
     end
    
    def all
      @hash.values
    end
    
  end
end