#coding:utf-8
class PartRelMeta < ActiveRecord::Base
  attr_accessible :saleNo, :purchaseNo
  belongs_to :client_part
  belongs_to :supplier_part

  # ---------------------------------------------
  #ws : for redis search
  # include Redis::Search
  # redis_search_index(:title_field => :key,
                     # :alias_field => :alias,
                     # :prefix_index_enable => true,
                     # :condition_fields=>[:orgIds],
                     # :ext_fields => [:cpartId,:spartId,:saleNo,:purchaseNo])
  # def alias
    # cpart=Part.find(cpartId)
    # spart=Part.find(spartId)
    # [cpart.partNr,spart.partNr,self.saleNo,self.purchaseNo]
  # end
# 
  # def orgIds
    # orgids=[]
    # orgids<<Part.find(self.cpartId).orgId
    # orgids<<Part.find(self.spartId).orgId
    # orgids
  # end
  #-----------------------------

  def self.generate_cs_partRel_meta_set_key cid,sid,partKey
    "clientId:#{cid}:supplierId:#{sid}:#{partKey}:metaset"
  end

end