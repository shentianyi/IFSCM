class Warehouse < ActiveRecord::Base
  self.inheritance_column = "not_used_type"
  attr_accessible :nr, :name, :type, :state
  
  belongs_to :organisation
  has_many :positions
  has_many :storage_histories, :through=>:positions
  
  # [功能：] 所有仓库列表。
  def self.selection_list( org )
    org.warehouses.map {|o| [o.nr, o.id] }
  end
  
  # [功能：] 可以正常入库的仓库列表。
  def self.selection_normal_list( org )
    org.warehouses.where(:type=>WarehouseType::Normal).map {|o| [o.nr, o.id] }
  end
  
end
