class Storage < ActiveRecord::Base
  attr_accessible :stock, :state
  attr_accessible :delivery_item_id
  
  belongs_to :part
  belongs_to :position
  
  scope :by_part, lambda { |partNr| joins(:part).where('parts.partNr'=>partNr) }
  
  validates :delivery_item_id, :uniqueness => true
  
  def self.return_denied( list )
    return nil  unless list.is_a?(Array)
    arr = where(:delivery_item_id=>list, :state=>StorageState::Out).map{ |s| s.delivery_item_id }
    return nil  if arr.blank?
    return arr
  end
end
