namespace :db do
  
  desc "Prints the schema lists"
  task :schema_list => :environment do
    puts ActiveRecord::Base.connection.select_values('select version from schema_migrations order by version')
  end
  
  # [功能：] 将需求从 Redis 转入 Mysql ，代表需求过期。
  desc "Transform Redis to Mysql ... ..."
  task :redis_to_mysql => :environment do
      puts "Transform Redis to Mysql ... ..."
      demands, total = Demander.search(:end=>Time.now.to_i )
      demands.each do |d|
          puts "--#{d.key}:"
          # d.instance_variable_get("@attributes").each do |k,v|
            # puts "---------------------#{k}---------------------------------#{v}"
          # end
          if d.save
              $redis.srem( "#{Rns::C}:#{d.clientId}", d.key )
              $redis.srem( "#{Rns::S}:#{d.supplierId}", d.key )
              $redis.srem( "#{Rns::RP}:#{d.relpartId}", d.key )
              $redis.zrem( Rns::Date, d.key )
              $redis.zrem( Rns::Amount, d.key )
              $redis.srem( "#{Rns::T}:#{d.type}", d.key )
          end
      end
  end
  
  
end