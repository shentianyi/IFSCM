class Strategy < ActiveRecord::Base
  attr_accessible :leastAmount, :needCheck
  attr_accessible :part_rel_id
 
  belongs_to :part_rel
  
end
