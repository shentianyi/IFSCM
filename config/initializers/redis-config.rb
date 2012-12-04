require "redis"
require "redis-namespace"
require "redis-search"
# don't forget change namespace
$redis = Redis.new(:host => "127.0.0.1",:port => "6379")
# ## global redis
 # redisBase=Redis.current
redisBase=$redis

# redis resque
Resque.redis=redisBase
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

# redis search db 3
# We suggest you use a special db in Redis, when you need to clear all data, you can use flushdb command to clear them.
redisBase.select(3)
# Give a special namespace as prefix for Redis key, when your have more than one project used redis-search, this config will make them work fine.
serach_redis = Redis::Namespace.new("rse", :redis => redisBase)

Redis::Search.configure do |config|
  config.redis = serach_redis
  config.complete_max_length = 100
  config.pinyin_match = true
end


