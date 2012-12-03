namespace :taskt do
  task :puts_staffs =>:environment do
    Staff.all.each do |s|
      puts s.name
    end 
    
      puts ENV['staff']
      
      puts ENV['staff'].class
  end
end