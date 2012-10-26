module CZ
  class BaseClass
    def initialize args={}
      if args.count>0
        args.each do |k,v|
          instance_variable_set "@#{k}",v
        end
      end
    end

    def save
      return false  if $redis.exists @key
      instance_variables.each do |attr|
       $redis.hset @key,attr.to_s.sub(/@/,''),instance_variable_get(attr) if instance_variable_defined?(attr)
      end
      return true
    end

    def self.find key
      if $redis.exists key
        c=self.new
        ($redis.hgetall key).each do |k,v|
          c.instance_variable_set "@#{k}",v
        end
      return c
      end
      return nil
    end
    
  end

end