class Strategy < ActiveRecord::Base
  attr_accessible :leastAmount, :needCheck
  attr_accessible :part_rel_id

  belongs_to :part_rel
  
  after_create :dod
  after_update :dod
  
  def dod
    puts "***********"
    puts self.id
        puts "***********"
   if self.needCheck_change
     puts "_______________________________________**"
   end
  end
end
