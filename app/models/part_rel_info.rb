#encoding: utf-8
require 'base_class'

class PartRelInfo<CZ::BaseClass
  attr_accessor :part_rel_id,:cpartNr,:spartNr,:saleNo, :purchaseNo,:leastAmount, :needCheck,
                :demote,:demote_times,:position_id,:check_passed_times,:position_nr
  
  def save
    self.key=PartRelInfo.generate_key(self.part_rel_id)
    super
  end
  
  def update attrs={}
    self.key=PartRelInfo.generate_key(self.part_rel_id)
    super
  end
  
  def destroy
    self.key=PartRelInfo.generate_key(self.part_rel_id)
    super
  end
  
  def self.find part_rel_id
    key=generate_key(part_rel_id)
    super(key)
  end
  
  private
  def self.generate_key part_rel_id
    "part_rel_info:#{part_rel_id}"
  end
end