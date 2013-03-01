class StorageHistory < ActiveRecord::Base
  attr_accessible :opType, :amount, :cost_center_name
  attr_accessible :position_id, :part_id
  
  belongs_to :position
  belongs_to :part
  
  
end
