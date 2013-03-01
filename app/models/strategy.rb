class Strategy < ActiveRecord::Base
  attr_accessible :leastAmount, :needCheck
  attr_accessible :part_rel_id
  after_create :dod
  after_update :dod
  belongs_to :part_rel
  
  def dod
    puts "***********"
    puts self.id
        puts "***********"
   if self.needCheck_change
     puts "_______________________________________**"
   end
  end
end
