class CreateMOrganisations < ActiveRecord::Migration
  def change
    create_table :m_organisations do |t|
      t.string :name
      t.string :description
      t.string :address
      t.string :tel
      t.string :website
      t.string :abbr
      t.string :contact
      t.string :email

      t.timestamps
    end
  end
end
