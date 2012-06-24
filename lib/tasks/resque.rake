require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
  ENV['RAILS_ENV'] ||= 'development'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
  Resque::Scheduler.dynamic = true
  #Resque.schedule = YAML.load_file("#{Rails.root.to_s}/config/resque_schedule.yml")
end

#task "jobs:work" => "resque:scheduler"
