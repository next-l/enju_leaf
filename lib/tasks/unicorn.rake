# see: http://qiita.com/items/118bce7b3a4acb545d79
# Unicorn用に起動/停止タスクを変更
rails_env = 'production'
application = 'enju_trunk'
app_root = "/opt/enju_trunk"

namespace :enju_trunk do
  namespace :unicorn do	
    desc 'start unicorn.'
    task :start => :environment do 
      sh "cd #{app_root}; bundle exec unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
    end
    desc 'restart unicorn.'
    task :restart do
      if File.exist? "/tmp/unicorn_#{application}.pid"
        sh "kill -s USR2 `cat /tmp/unicorn_#{application}.pid`"
        sh "kill -s QUIT `cat /tmp/unicorn_#{application}.pid`"
      end
    end
    desc 'stop unicorn.'
    task :stop do
      sh "kill -s QUIT `cat /tmp/unicorn_#{application}.pid`"
    end
  end
end

