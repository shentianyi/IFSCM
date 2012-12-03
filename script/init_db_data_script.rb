class InitDBDataScript
  def self.init_staff args
    args.each do |arg|
      puts Staff.new(:staffNr => arg[:staffNr], :name=>arg[:name],:password => arg[:pass],  :password_confirmation => arg[:conpass]).save!
    end
  end
end

# args=[{:staffNr =>'DataAdmin', :name=>'DataAdmin',:pass =>"123456@",  :conpass =>"123456@"}]
# InitDBDataScript.init_staff args
