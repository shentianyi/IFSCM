# 1. init part data
require 'redis'
require 'enum/part_rel_type'

class InitRedisData
  # init demand type
  def self.initDemandType
    $redis.del DemandType.gen_set_key
    ['D','W','M','Y','T'].each do |t|
      $redis.sadd DemandType.gen_set_key,t
    end
  end
end
 
InitRedisData.initDemandType 
