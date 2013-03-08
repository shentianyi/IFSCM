class AddDemoteDemoteTimesPositionIdCheckPassedTimesToStrategies < ActiveRecord::Migration
  def change
     add_column :strategies, :demote, :boolean,:default=>false
     add_column :strategies, :demote_times, :integer,:default=>1
     add_column :strategies, :position_id,:integer
     add_column :strategies, :check_passed_times,:integer,:default=>0
  end
end
