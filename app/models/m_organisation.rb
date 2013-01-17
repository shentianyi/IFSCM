class MOrganisation < ActiveRecord::Base
  attr_accessible :name, :description, :address, :tel, :website, :abbr, :contact, :email
  has_many :clients, :class_name=>"MOrganisationRelation", :foreign_key=>"origin_supplier_id"
                    # :conditions=>['m_parts.part_poly_type = ?', "Supplier"]
  has_many :suppliers, :class_name=>"MOrganisationRelation", :foreign_key=>"origin_client_id"
  has_many :cli_req_parts, :through=>:clients, :source=>:supplier_parts
  has_many :sup_res_parts, :through=>:suppliers, :source=>:client_parts
  
  
end
