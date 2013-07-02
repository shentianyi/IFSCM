#encoding: utf-8
class Position < ActiveRecord::Base
  attr_accessible :nr, :capacity
  attr_accessible :warehouse_id
  belongs_to :warehouse
  has_many :storages
  has_many :storage_histories
  
  scope :by_partId, lambda { |partId| joins(:storages=>:part).select("positions.*, parts.partNr, sum(storages.stock) as total").group("positions.id").where('parts.id'=>partId) }
  
  # [功能：] 库存量求和。
  def stock
    self.storages.sum(:stock)
  end
    
  # [功能：] （根据零件）库存量求和。
  def stock_by_partId( partId )
    self.storages.by_partId(partId).sum(:stock)
  end
end
