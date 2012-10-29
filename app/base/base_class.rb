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
      return self.new($redis.hgetall key)
      end
      return nil
    end

    def destory
      if $redis.exists @key
        $redis.del @key
      return true
      end
      return false
    end

  end
end