class Warehouse < ActiveRecord::Base
  attr_accessible :nr, :name
  
  belongs_to :organisation
  has_many :positions
end
