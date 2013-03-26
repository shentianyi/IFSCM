class AddAcceptedToDemander < ActiveRecord::Migration
  def change
    add_column :demanders, :accepted, :boolean, :default=>false
  end
end
