class Part < ActiveRecord::Base
  attr_accessible :partNr
  belongs_to :organisation
  has_many :client_part_rels, :class_name=>"PartRel", :foreign_key=>"client_part_id" # org is client
  has_many :supplier_part_rels, :class_name=>"PartRel", :foreign_key=>"supplier_part_id" # org is supplier
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

