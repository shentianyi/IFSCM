class OrderItem < ActiveRecord::Base
  attr_accessible :orderNr, :total, :rest, :transit, :receipt
  attr_accessible :organisation_id, :supplier_id, :demander_key
  
  belongs_to :organisation
  belongs_to :supplier, :class_name=>"Organisation", :foreign_key=>"supplier_id"
end
