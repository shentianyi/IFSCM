require 'base_class'

class Part<CZ::BaseClass
  attr_accessor :key,:orgId,:partNr
  
  def self.gen_key
    "part:#{$redis.incr('part_index_incr')}"
  end
  
  
  # redis search -----------------------------
  include Redis::Search
  
  redis_search_index(:title_field => :partNr,
                     :alias_field => :alias,
                     :prefix_index_enable => true,
                     :condition_fields=>[:orgId],
                    :score_field=>:created_at,
                     :ext_fields =>  [:key,:partNr])

  def alias
    [self.partNr]
  end

  def rank
    self.created_at
  end
  # -------------------------------------------------
  
  def self.find_partId_by_orgId_partNr orgId,partNr
    $redis.hget 'orgId:'+orgId.to_s+':parts',partNr
  end
 
 

end