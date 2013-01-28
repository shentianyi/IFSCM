

# After changes, do below:
# whenever --update-crontab ifscm  --set environment=development
#
every :day, :at => '11:59 pm' do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  rake 'db:redis_to_mysql'
end

