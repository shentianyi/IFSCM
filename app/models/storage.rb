class Storage < ActiveRecord::Base
  attr_accessible :stock
  
  belongs_to :part
  belongs_to :position
end
