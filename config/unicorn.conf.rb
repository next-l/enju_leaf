# http://github.com/blog/517-unicorn

rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes (rails_env == 'production' ? 16 : 4)
preload_app true
timeout 30

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  old_pid = Rails.root.to_s + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    #begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    #rescue Errno::ENOENT, Errno::ESRCH
    #end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
