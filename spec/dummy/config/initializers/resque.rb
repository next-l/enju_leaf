require 'resque/server'
require 'resque/scheduler/server'
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
