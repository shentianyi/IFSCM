class MPartRelMeta < ActiveRecord::Base
  attr_accessible :saleNo, :purchaseNo
  belongs_to :client_part
  belongs_to :supplier_part
end
