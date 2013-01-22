namespace :db do
  
  desc "Prints the schema lists"
  task :schema_list => :environment do
    puts ActiveRecord::Base.connection.select_values('select version from schema_migrations order by version')
  end
  
end