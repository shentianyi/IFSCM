class Part < ActiveRecord::Base
  attr_accessible :partNr
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



class ClientPart < Part
  # attr_accessible :title, :body
  belongs_to :organisation_relation
  has_one :partRelMeta, :class_name=>"PartRelMeta"
end



class SupplierPart < Part
  # attr_accessible :title, :body
  belongs_to :organisation_relation
  has_one :partRelMeta, :class_name=>"PartRelMeta"
end