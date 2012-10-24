module CZ
  class BaseClass
    def initialize args={}
      if args.count>0
        args.each do |k,v|
          instance_variable_set "@#{k}",v
        end
      end
    end
  end
end