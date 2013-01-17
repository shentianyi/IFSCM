class CreateMDemanders < ActiveRecord::Migration
  def change
    create_table :m_demanders do |t|

      t.timestamps
    end
  end
end
