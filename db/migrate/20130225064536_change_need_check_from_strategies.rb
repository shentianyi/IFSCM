class ChangeNeedCheckFromStrategies < ActiveRecord::Migration
  def change
    change_column :strategies,:needCheck,:integer,:default=>DeliveryObjInspect::ExemInspect  
  end
end
