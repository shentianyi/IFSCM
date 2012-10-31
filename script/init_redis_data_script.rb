# 1. init part data
require 'redis'

redis=Redis.new
class InitData
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

InitData.initPart
