if defined?(Resque)
  Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
