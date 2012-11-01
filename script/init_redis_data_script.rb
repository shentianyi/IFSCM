# 1. init part data
require 'redis'
 
class InitData
  
  # init demand type in redis
  def self.initDemandType
    $red.del DemandType.gen_set_key
    ['D','W','M','Y'].each do |t| 
       $redis.sadd DemandType.gen_set_key,t
    end
  end
  
  # init demand Part in redis
  def self.initPart
    for j in 1..2 do
      for i in 1...10 do
        key=Part.gen_key
        p=Part.new(:key=>key,:orgId=>j,:partNr=>"PartNr"+((10*(j-1))+i).to_s)
        p.save
        puts p.partNr
      end
    end
  end
end
InitData.initDemandType
# InitData.initPart
