# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Demand::Application.initialize!

#  passenger unintentional file descriptor sharing
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      require 'redis'
      $redis.client.disconnect
      $redis=Redis.new(:host => "127.0.0.1",:port => "6379")
      
      $redisBase.client.disconnect
      $redisBase=Redis.new(:host => "127.0.0.1",:port => "6379",:db=>3)
    end
  end
end
