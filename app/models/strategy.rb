class Strategy < ActiveRecord::Base
  attr_accessible :leastAmount, :needCheck,:demote,:demote_times,:position_id,:check_passed_times
  attr_accessible :part_rel_id
 
  belongs_to :part_rel
  after_update :update_part_rel_info
  after_create :update_part_rel_info
  
  # private
  def update_part_rel_info
      attr={}
    # if self.leastAmount_change
      attr[:leastAmount]=self.leastAmount
    # end
    # if self.needCheck_change
      attr[:needCheck]=self.needCheck
    # end
    # if self.demote_change
      attr[:demote]=self.demote
    # end
    # if self.demote_times_change
      attr[:demote_times]=self.demote_times
    # end
    if self.position_id_change
      attr[:position_id]=self.position_id     
      posi=Position.find(self.position_id)
      attr[:position_nr]=posi.nr
      attr[:warehouse_id]=posi.warehouse_id
    end
    # if self.check_passed_times_change
      attr[:check_passed_times]=self.check_passed_times
    # end
    # if attr.length>0
      if pinfo=PartRelInfo.find(self.part_rel_id)
        pinfo.update(attr)
      end
    # end
  end
end
