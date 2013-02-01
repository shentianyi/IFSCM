class PackageInfo < ActiveRecord::Base
  attr_accessible :leastAmount
  attr_accessible :part_rel_id
  
  belongs_to :part_rel
end
