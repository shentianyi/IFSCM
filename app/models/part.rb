class Part < ActiveRecord::Base
  attr_accessible :partNr
  belongs_to :organisation
    has_many :client_part_rels, :class_name=>"PartRel", :foreign_key=>"client_part_id" # org is client
                    # :conditions=>['m_parts.part_poly_type = ?', "Supplier"]
  has_many :supplier_part_rels, :class_name=>"PartRel", :foreign_key=>"supplier_part_id" # org is supplier
  # belongs_to :client_part, :class_name=>"Part"#, :foreign_key=>"client_part_id"
  # belongs_to :supplier_part, :class_name=>"Part"#, :foreign_key=>"supplier_part_id"
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


# 
# class ClientPart < PartRel
  # # attr_accessible :title, :body
  # belongs_to :organisation_relation
  # has_one :partRelMeta, :class_name=>"PartRelMeta"
# end
# 
# 
# class SupplierPart < PartRel
  # # attr_accessible :title, :body
  # belongs_to :organisation_relation
  # has_one :partRelMeta, :class_name=>"PartRelMeta"
# end