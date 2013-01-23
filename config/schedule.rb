
# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every :day, :at => '01:00am' do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  rake 'db:redis_to_mysql'
end

# Learn more: http://github.com/javan/whenever
