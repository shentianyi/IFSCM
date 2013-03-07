class Warehouse < ActiveRecord::Base
  attr_accessible :nr, :name,:type,:state
  
  belongs_to :organisation
  has_many :positions
  has_many :storage_histories, :through=>:positions
  
  def self.selection_list( org )
    org.warehouses.map {|o| [o.nr, o.id] }
  end
  
end
