class RedisCsvFile
  attr_accessor :index,:oriName,:valid,:itemsCount,:uuidName,:errorCount,:normalKey,:errorKey
  
  def initialize args={}
    if args.count>0
     args.each do |k,v|
       instance_variable_set "@#{k}",v
      end
    end
  end
  
  def save_in_redis
    
  end
end