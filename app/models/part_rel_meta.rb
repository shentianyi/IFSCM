require 'base_class'

class PartRelMeta<CZ::BaseClass
  attr_accessor :key,:cpartId,:spartId
  
   def self.gen_key
    "partrelmeta:#{$redis.incr('partrelmeta_index_incr')}"
  end
  
end