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

    def self.included(base)      
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

    end

  end
end