#encoding: utf-8

module CZ
  module DeliveryBase
    attr_accessor :items
    def add_to_parent
      key=eval(self.class.name).generate_child_zset_key self.parentKey
      $redis.zadd key,DeliveryBll.delivery_obj_reconverter(self.class.name),self.key
    end

    def remove_from_parent
      key=eval(self.class.name).generate_child_zset_key self.parentKey
      $redis.zrem key,self.key
    end

    def update_redis_id
      self.rupdate(:id=>self.id)
    end

    def update_state_wayState
      if self.wayState_change
        self.rupdate(:wayState=>self.wayState)
      end
      if self.state_change
        self.rupdate(:state=>self.state)
      end
    end

    def self.included(base)
      def base.single_or_default key,mysql=false
        obj=nil
        if mysql
          obj=find_from_mysql key
        else
          unless obj=find_from_redis(key)
            obj=find_from_mysql key
          end
        end
        return obj
      end
      
      def base.rexists key
        $redis.exists key
      end
      
      def base.get_children key,startIndex,endIndex
        key=generate_child_zset_key key
        total=$redis.zcard key
        if total>0
          if  (keys=$redis.zrange(key,startIndex,endIndex,:withscores=>true)).count>0
            items=[]
            keys.each do |k,s|
              i=eval(DeliveryBll.delivery_obj_converter s).rfind(k)
              items<<i
            end
          return items,total
          end
        end
        return nil
      end

      def base.generate_child_zset_key key
        "delivery:#{key}:child:zset"
      end

      def base.find_from_mysql key
        where(:key=>key).first
      end

      def base.find_from_redis key
        rfind(key)
      end
    end

  end
end