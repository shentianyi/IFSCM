#encoding: utf-8
class Organisation < ActiveRecord::Base
  attr_accessible :name, :description, :address, :tel, :website, :abbr, :contact, :email
  
  has_many :clients, :class_name=>"OrganisationRelation", :foreign_key=>"origin_supplier_id"
  has_many :suppliers, :class_name=>"OrganisationRelation", :foreign_key=>"origin_client_id"
  has_many :parts
  has_many :delivery_notes
  has_many :warehouses
  has_many :cost_centers
  has_many :order_items
  has_many :client_order_items, :class_name=>"OrderItem", :foreign_key=>"supplier_id"

  include Redis::Search
  redis_search_index(:title_field => :name,
                     :alias_field => :alias,
                     :prefix_index_enable => true,
                     :ext_fields => [:contact, :email])
                     
  def alias
    [self.description, self.address, self.website, self.abbr ]
  end
  
  def alias_was
    [self.description_was, self.address_was, self.website_was, self.abbr_was ]
  end
                     
end

