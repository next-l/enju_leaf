# https://github.com/resque/resque/wiki/RSpec-and-Resque
RSpec.configure do |config|
  REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
  REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"

<<<<<<< HEAD
  config.before(:suite) do
    redis_options = {
      "daemonize"     => 'yes',
      "pidfile"       => REDIS_PID,
      "port"          => 9736,
      "timeout"       => 300,
      "save 900"      => 1,
      "save 300"      => 1,
      "save 60"       => 10000,
      "dbfilename"    => "dump.rdb",
      "dir"           => REDIS_CACHE_PATH,
      "loglevel"      => "debug",
      "logfile"       => "stdout",
      "databases"     => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
    `echo '#{redis_options}' | redis-server -`
  end
=======
  unless ENV["TRAVIS"]
    Resque.redis = 'localhost:9736'
    config.before(:suite) do
      redis_options = {
        "daemonize"     => 'yes',
        "pidfile"       => REDIS_PID,
        "port"          => 9736,
        "timeout"       => 300,
        "save 900"      => 1,
        "save 300"      => 1,
        "save 60"       => 10000,
        "dbfilename"    => "dump.rdb",
        "dir"           => REDIS_CACHE_PATH,
        "loglevel"      => "debug",
        "logfile"       => "stdout",
        "databases"     => 16
      }.map { |k, v| "#{k} #{v}" }.join("\n")
      `echo '#{redis_options}' | redis-server -`
    end
>>>>>>> ed1bddb... updated UserImportFile#modify

  config.after(:suite) do
    %x{
      cat #{REDIS_PID} | xargs kill -QUIT
      rm -f #{REDIS_CACHE_PATH}dump.rdb
    }
  end
end
