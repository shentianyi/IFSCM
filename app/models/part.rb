require 'base_class'

class Part<CZ::BaseClass
  attr_accessor :key,:orgId,:partNr
  
  def self.gen_key
  $redis.incr('part:index:incr')
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

  def self.exist_by_partId partId
    $redis.sismember 'partId:set',partId.to_s
  end

  # def self.exist_by_partNr partNr
  # $redis.sismber 'partNr:set',partNr
  # end---usless,because the partNr is following the org
  def self.find_partId_by_orgId_partNr orgId,partNr
    $redis.hget 'orgId:'+orgId.to_s+':parts',partNr
  end

  def self.get_supplier_partIds clientId,supplierId,cpartId
    pv=$redis.hget('clientId:'+clientId.to_s+':supplierId:'+supplierId.to_s+':cspartRel',cpartId)
    if pv
      ps=$redis.smembers(pv)
      if ps and ps.count>0
        parts=[]
        ps.each do |p|
          parts<<$redis.hget(p,'partId')
        end
      return parts
      else
        return nil
      end
    else
      return nil
    end
  end

end