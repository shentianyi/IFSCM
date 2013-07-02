#encoding: utf-8
class CostCenter < ActiveRecord::Base
  attr_accessible :name, :desc
  attr_accessible :organisation_id
  
  belongs_to :organisation
  
  # [功能：] 成本中心的列表。
  def self.selection_list( org )
    org.cost_centers.map {|o| o.name }
  end
end
