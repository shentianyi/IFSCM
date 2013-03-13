class OrderItem < ActiveRecord::Base
  attr_accessible :orderNr, :total, :rest, :transit, :receipt
  attr_accessible :organisation_id, :demander_key
  
  belongs_to :organisation
end
