#coding:utf-8
class Organisation < ActiveRecord::Base
  attr_accessible :name, :description, :address, :tel, :website, :abbr, :contact, :email
  has_many :clients, :class_name=>"OrganisationRelation", :foreign_key=>"origin_supplier_id"
  has_many :suppliers, :class_name=>"OrganisationRelation", :foreign_key=>"origin_client_id"
  has_many :parts
  has_many :delivery_notes

  include Redis::Search
  redis_search_index(:title_field => :name,
                     :alias_field => :alias,
                     :prefix_index_enable => true,
                     :ext_fields => [:contact, :email])
                     
  def alias
    [self.description, self.address, self.website, self.abbr ]
  end
                     
end

