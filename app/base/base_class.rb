require 'active_support'

module CZ
  class BaseClass
    attr_accessor :created_at
    include ActiveSupport::Callbacks

    define_callbacks :update
    define_callbacks :destory
    define_callbacks :save
    define_callbacks :buildRSIndex
    def initialize args={}
      if args.count>0
        args.each do |k,v|
          instance_variable_set "@#{k}",v
        end
      end
    end

    def save
      return false  if $redis.exists(@key)
      instance_variables.each do |attr|
        $redis.hset @key,attr.to_s.sub(/@/,''),instance_variable_get(attr)
      end
      t=Time.now.to_i
      $redis.hset @key,'created_at',t
      self.created_at=t
      run_callbacks :save
      return true
    end
    
    def cover
       instance_variables.each do |attr|
        $redis.hset @key,attr.to_s.sub(/@/,''),instance_variable_get(attr)
      end
    end

    def update attrs={}
       return false  unless $redis.exists(@key)
      if attrs.count>0
        attrs.each do |k,v|
          instance_variable_set "@#{k}",v
          $redis.hset @key,k,v
        end
      end
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

   # for build Redis Serach Index 
   def buildRSIndex
     run_callbacks :buildRSIndex
   end
   
  end
end