

# After changes, do below:
# whenever --update-crontab ifscm  --set environment=development
#
every :day, :at => '23:55 pm' do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  rake 'db:redis_to_mysql'
end

