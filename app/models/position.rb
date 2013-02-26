class Position < ActiveRecord::Base
  attr_accessible :nr, :capacity
  
  belongs_to :warehouse
  has_many :storages
  
  scope :by_part, lambda { |partNr| joins(:storages=>:part).where('parts.partNr'=>partNr) }
  
  def stock
    self.storages.sum(:stock)
  end
end
