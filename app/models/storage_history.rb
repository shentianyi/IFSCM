class StorageHistory < ActiveRecord::Base
  attr_accessible :opType, :amount
  attr_accessible :position_id, :part_id
  
  belongs_to :position
  belongs_to :part
  
  
end
