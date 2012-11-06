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

  def self.find_partKey_by_orgId_partNr orgId,partNr
    hash_key=generate_org_part_set_key orgId
    $redis.hget hash_key,partNr
  end

  def add_to_org orgId
    hash_key=Part.generate_org_part_set_key orgId
    $redis.hset hash_key,@partNr,@key
  end

  private

  def self.generate_org_part_set_key orgId
    "orgId:#{orgId}:parts"
  end
  
end