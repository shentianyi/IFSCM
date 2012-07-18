require 'base_class'

class PartRelMeta<CZ::BaseClass
  attr_accessor :key,:cpartId,:spartId,:saleNo,:purchaseNo

  # ws : for redis search
  # include Redis::Search
  # redis_search_index(:title_field => :proNr,
                     # :alias_field => :alias,
                     # :prefix_index_enable => true,
                     # :score_field => :rank,
                     # :ref=>{:key=>:proKey,:class=>:Project,:fields=>[:full_name,:name,:description]},
                     # :ext_fields => [:proNr,:key,:proKey])
  # def alias
    # cpart=Part.find(cpartId)
    # spart=Part.find(spartId)
    # [pro.name,pro.full_name,pro.description]
  # end

  #--------------------

  def self.gen_key
    "partrelmeta:#{$redis.incr('partrelmeta_index_incr')}"
  end

end