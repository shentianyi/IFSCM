class MOrganisationRelation < ActiveRecord::Base
  attr_accessible :supplierNr, :clientNr
  belongs_to :origin_supplier, :class_name=>"MOrganisation"#, :foreign_key=>"origin_supplier_id"
  belongs_to :origin_client, :class_name=>"MOrganisation"#, :foreign_key=>"origin_client_id"
  has_many :client_parts
  has_many :supplier_parts
  
end
