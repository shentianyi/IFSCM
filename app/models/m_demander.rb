class MDemander < ActiveRecord::Base
  attr_accessible :clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate
end
