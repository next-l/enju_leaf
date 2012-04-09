Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 12.hours
Delayed::Worker.backend = :active_record
Delayed::Worker.delay_jobs = !Rails.env.test?

Delayed::Worker.logger = 
  ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_jobs.log", Rails.logger.level)
#if caller.last =~ /.*\/script\/delayed_job:\d+$/
#  ActiveRecord::Base.logger = Delayed::Worker.logger
#end

