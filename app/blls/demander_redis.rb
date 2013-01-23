#coding:utf-8
module DemanderRedis
    def save_to_redis
      if self.key.nil?
        if gk=ClassKeyHelper::gen_key(self.class.name)
          self.key=gk
        end
        self.created_at=Time.now.to_i
        @attributes.each do |k,v|
          $redis.hset(self.key, k, v)
        end
        return true
      else
        return false
      end
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

    # def self.included(base)
        # def base.rfind( key )
          # return self.new($redis.hgetall key)   if $redis.exists key
          # return nil
        # end
    # end

    def rdestroy
      if $redis.exists self.key
        $redis.del self.key
        return true
      end
      return false
    end
    
  def save_to_send
    $redis.sadd( "#{Rns::C}:#{clientId}", key )
    $redis.sadd( "#{Rns::S}:#{supplierId}", key )
    $redis.sadd( "#{Rns::RP}:#{relpartId}", key )
    d = FormatHelper::demand_date_to_date( date,type )
    $redis.zadd( Rns::Date, d.to_i, key )
    $redis.zadd( Rns::Amount, amount, key )
    $redis.sadd( "#{Rns::T}:#{type}", key )
  end
  
  def save_to_send_update
    $redis.zrem( Rns::Amount, key )
    $redis.zadd( Rns::Amount, amount, key )
  end
  
  def self.included(base)
        def base.rfind( key )
          if $redis.exists key
            ob = self.new
            ob.rupdate($redis.hgetall key)
            return ob
          end
          return nil
        end
      
      def base.search( hash )
        list = []
        resultKey = "resultKey_temp_#{$redis.incr('resultKey_temp_')}"
        ###########################  client
        if client = union_params( Rns::C, hash[:clientId] )
        list<<client
        end
        ###########################  supplier
        if supplier = union_params( Rns::S, hash[:supplierId] )
        list<<supplier
        end
        ###########################  part
        if relpart = union_params( Rns::RP, hash[:rpartNr] )
        list<<relpart
        end
        ###########################  type
        if type = union_params( Rns::T, hash[:type] )
        list<<type
        end
        ###########################  date
        list<<Rns::Date
    
        $redis.zinterstore( resultKey, list, :aggregate=>"MAX" )
    
        demands = []
        amount = hash[:amount]
        if amount&&amount.size>0
          if amount.size==1
          start = amountend = amount
          elsif amount.size==2 && amount.last.size==0
          start = amount.first
          amountend = $Infin
          elsif amount.size==2
          start = amount.first
          amountend = amount.last
          end
          $redis.zinterstore( resultKey, [resultKey, Rns::Amount], :weights=>[0,1] )
    
          if hash[:page]
            total = $redis.zcount( resultKey, start, amountend )
            $redis.zrangebyscore( resultKey, start, amountend, :withscores=>false, :limit=>[(hash[:page].to_i)*NumPer, NumPer] ).each do |item|
              demands << Demander.find( item )
            end
          else
            $redis.zrangebyscore( resultKey, start, amountend, :withscores=>false).each do |item|
              demands << Demander.find( item )
            end
          end
        else
          start = (hash[:start]&&hash[:start].size>0) ? hash[:start].to_i : -$Infin
          timeend = (hash[:end]&&hash[:end].size>0) ? hash[:end].to_i : $Infin
          if hash[:page]
            total = $redis.zcount( resultKey, start, timeend )
            $redis.zrangebyscore( resultKey, start, timeend, :withscores=>false, :limit=>[(hash[:page].to_i)*NumPer, NumPer] ).each do |item|
              demands << Demander.find( item )
            end
          else
            $redis.zrangebyscore( resultKey, start, timeend, :withscores=>false).each do |item|
              demands << Demander.find( item )
            end
          end
        end
    
        $redis.expire( resultKey, 30 )
        return demands, total
      end
  
      private
    
      def base.union_params( column, param )
        return false unless param && param.size>0
        if param.is_a?(String)
          key = "#{column}:#{param}"
        elsif param.is_a?(Array)
          key = column
          param.uniq.each do |c|
            c.insert( 0, "#{column}:" )
          end
        $redis.zunionstore( key, param )
        key
        else
        return false
        end
      end
  
  end
  
end