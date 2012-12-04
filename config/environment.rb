# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Demand::Application.initialize!

#  passenger unintentional file descriptor sharing
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      #Redis.current.client.reconnect
      $redis.client.reconnect
    end
  end
end
