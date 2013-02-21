class Position < ActiveRecord::Base
  attr_accessible :nr, :capacity
  
  belongs_to :warehouse
  has_many :storages
end
