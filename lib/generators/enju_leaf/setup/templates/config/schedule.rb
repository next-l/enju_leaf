# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :path, '/path/to/enju_leaf'
set :environment, :development
set :output, "#{path}/log/cron_log.log"

every 1.hour do
  rake "enju_biblio:import"
end

every 1.day, :at => '0:00 am' do
  runner "User.lock_expired_users"
end

every 1.day, :at => '3:00 am' do
  rake "sunspot:reindex"
#  rake "sitemap:refresh:no_ping"
end

every 1.day, :at => '5:00 am' do
  rake "enju:import:destroy"
end
