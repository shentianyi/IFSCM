require 'active_support'

module CZ
  class BaseClass
    attr_accessor :created_at
    include ActiveSupport::Callbacks

    define_callbacks :update
    define_callbacks :destory
    define_callbacks :save
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
        $redis.hset @key,attr.to_s.sub(/@/,''),instance_variable_get(attr)
      end
      $redis.hset @key,'created_at',Time.now.to_i
      run_callbacks :save
      return true
    end

    def update
      run_callbacks :update
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
        run_callbacks :destory
      return true
      end
      return false
    end

  end
end