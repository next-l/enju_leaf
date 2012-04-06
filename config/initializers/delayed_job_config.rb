Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
#Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.max_run_time = 12.hours
Delayed::Worker.backend = :active_record
Delayed::Worker.delay_jobs = !Rails.env.test?
