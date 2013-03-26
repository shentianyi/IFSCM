class Position < ActiveRecord::Base
  attr_accessible :nr, :capacity
  attr_accessible :warehouse_id
  belongs_to :warehouse
  has_many :storages
  has_many :storage_histories
  
  scope :by_partId, lambda { |partId| joins(:storages=>:part).select("positions.*, parts.partNr, sum(storages.stock) as total").group("positions.id").where('parts.id'=>partId) }
  
  def stock
    self.storages.sum(:stock)
  end
    
  def stock_by_partId( partId )
    self.storages.by_partId(partId).sum(:stock)
  end
end
