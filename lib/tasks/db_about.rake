namespace :db do
  
  desc "Prints the schema lists"
  task :schema_list => :environment do
    puts ActiveRecord::Base.connection.select_values('select version from schema_migrations order by version')
  end
  
  
  desc "Transform Redis to Mysql ... ..."
  task :redis_to_mysql => :environment do
      puts "Transform Redis to Mysql ... ..."
      demands, total = Demander.search( :clientId=>nil, :supplierId=>nil,
              :rpartNr=>nil, :start=>Time.parse("2012/1/1").to_i, :end=>Time.now.to_i,
              :type=>nil,  :amount=>nil,
              :page=>nil )
      puts total
      puts demands.each {|d|d.amount}
      demands.each do |d|
        
      end
  end
  
  
end