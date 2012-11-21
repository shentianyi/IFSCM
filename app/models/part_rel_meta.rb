require 'base_class'

class PartRelMeta<CZ::BaseClass
  attr_accessor :key,:cpartId,:spartId,:saleNo,:purchaseNo

  # ---------------------------------------------
  #ws : for redis search
  include Redis::Search
  redis_search_index(:title_field => :key,
                     :alias_field => :alias,
                     :prefix_index_enable => true,
                     :condition_fields=>[:orgIds],
                     :ext_fields => [:cpartId,:spartId,:saleNo,:purchaseNo])
  def alias
    cpart=Part.find(cpartId)
    spart=Part.find(spartId)
    [cpart.partNr,spart.partNr,self.saleNo,self.purchaseNo]
  end

  def orgIds
    orgids=[]
    orgids<<Part.find(self.cpartId).orgId
    orgids<<Part.find(self.spartId).orgId
    orgids
  end
#-----------------------------

  def self.gen_key
    "partrelmeta:#{$redis.incr('partrelmeta_index_incr')}"
  end
end