#coding:utf-8
class PartRel < ActiveRecord::Base
  attr_accessible :saleNo, :purchaseNo
  attr_accessible :client_part_id, :supplier_part_id, :organisation_relation_id
  # belongs_to :part
  belongs_to :organisation_relation
  belongs_to :client_part, :class_name=>"Part"#, :foreign_key=>"client_part_id"
  belongs_to :supplier_part, :class_name=>"Part"#, :foreign_key=>"supplier_part_id"
  # attr_accessor :orgId,:partNr

  # redis search -----------------------------
  # include Redis::Search

  # redis_search_index(:title_field => :partNr,
                     # :prefix_index_enable => true,
                     # :condition_fields=>[:orgId],
                    # :score_field=>:created_at,
                     # :ext_fields =>  [:key,:partNr])

  # -------------------------------------------------
  
end
