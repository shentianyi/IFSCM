require 'active_support'

module CZ
  class BaseClass
    attr_accessor :key,:created_at
    include ActiveSupport::Callbacks

    define_callbacks :update
    define_callbacks :destroy
    define_callbacks :save
    define_callbacks :buildRSIndex
    define_callbacks :cleanRSIndex
    def initialize args={}
      if args.count>0
        if !(args.key?(:key) or args.key?("key"))
          if gk=ClassKeyHelper::gen_key(self.class.name)
          self.key=gk
          end
        end
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

    def destroy
      if $redis.exists @key
        $redis.del @key
        run_callbacks :destroy
      return true
      end
      return false
    end

    def id
      ClassKeyHelper::decompose_key self.class.name,self.key
    end

    def self.get_key_by_id id
      ClassKeyHelper::compose_key name,id
    end

    # for build Redis Search Index
    def buildRSIndex
      run_callbacks :buildRSIndex
    end

    # for clean Redis Search Index
    def cleanRSIndex
      run_callbacks :cleanRSIndex
    end

  end
end