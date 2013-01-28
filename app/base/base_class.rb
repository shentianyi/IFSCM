#encoding: utf-8
# require 'active_support'
module CZ
  module BaseModule
    def save_to_redis
      return false if $redis.exists(self.key)
        if self.key.nil?
        if gk=ClassKeyHelper::gen_key(self.class.name)
          self.key=gk
        end
        end
        self.created_at=Time.now.to_i
        @attributes.each do |k,v|
          $redis.hset(self.key, k, v)
        end
        return true
    end

    def rupdate attrs={}
      if $redis.exists(self.key) && attrs.count>0
        attrs.each do |k,v|
          @attributes["#{k}"] = v
          $redis.hset(self.key, k, v)
        end
        return true
      else
        return false
      end
    end

    def self.included(base)
        def base.rfind( key )
          return self.new($redis.hgetall key)   if $redis.exists key
          return nil
        end
    end

    def rdestroy
      if $redis.exists self.key
        $redis.del self.key
        return true
      end
      return false
    end
    
  end
  
  class BaseClass
    attr_accessor :key,:created_at
    def initialize args={}
      if !(args.key?(:key) or args.key?("key"))
        if gk=ClassKeyHelper::gen_key(self.class.name)
        self.key=gk
        end
      end
      
      args.each do |k,v|
        instance_variable_set "@#{k}",v
      end
      
      if self.respond_to?(:default)
        self.default.each do |k,v|
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

  end
end