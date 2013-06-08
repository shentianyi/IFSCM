class Storage < ActiveRecord::Base
  attr_accessible :stock, :state
  attr_accessible :delivery_item_id,:part_id,:position_id
  
  belongs_to :part
  belongs_to :position
  
  scope :by_partId, lambda { |partId| where(:part_id=>partId).readonly(false) }
  
  # [功能：] 返回拒绝的运单项的列表。
  #在（delivery_controller > return_dn）中是唯一的引用，原本是用于拒收的吧，但是被注释掉了。————6月8日
  def self.return_denied( list )
    return nil  unless list.is_a?(Array)
    arr = where(:delivery_item_id=>list, :state=>StorageState::Out).map{ |s| s.delivery_item_id }
    return nil  if arr.blank?
    return arr
  end
end
