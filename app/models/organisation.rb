#coding:utf-8
class Organisation < ActiveRecord::Base
  attr_accessible :name, :description, :address, :tel, :website, :abbr, :contact, :email
  has_many :clients, :class_name=>"OrganisationRelation", :foreign_key=>"origin_supplier_id"
  has_many :suppliers, :class_name=>"OrganisationRelation", :foreign_key=>"origin_client_id"
  has_many :parts
  has_many :delivery_notes

end

class Rns

  C = "client"
  S = "supplier"
  Org = "organisation"

  De = "demand"
  T = "type"
  RP = "relpart"
  Date = "date"
  Amount = "amount"

  Kes = "kestrel"

end