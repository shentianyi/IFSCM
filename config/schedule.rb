

# After changes, do below:
# whenever --update-crontab ifscm  --set environment=development
#
every :day, :at => '00:05 am' do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  rake 'db:redis_to_mysql'
end

