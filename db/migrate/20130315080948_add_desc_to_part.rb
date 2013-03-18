class AddDescToPart < ActiveRecord::Migration
  def change
    add_column :parts, :desc, :string
  end
end
