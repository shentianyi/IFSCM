class Position < ActiveRecord::Base
  attr_accessible :nr, :capacity
  attr_accessible :warehouse_id
  belongs_to :warehouse
  has_many :storages
  has_many :storage_histories
  
  scope :by_part, lambda { |partNr| joins(:storages=>:part).where('parts.partNr'=>partNr) }
  
  def stock
    self.storages.sum(:stock)
  end
end
