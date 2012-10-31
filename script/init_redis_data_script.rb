# 1. init part data
require 'redis'

redis=Redis.new
class InitData
  def self.initPart
    for j in 1..3 do
      for i in 1...10 do
        key=Part.gen_key
        p=Part.new(:key=>key,:orgId=>j,:partNr=>"PartNr:"+key)
        p.save
        puts key
      end
    end
  end
end

InitData.initPart
