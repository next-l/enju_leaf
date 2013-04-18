opt_dir = "/opt"
backupdir = "/backup/app"
root = "#{::Rails.root}"

namespace :enju_trunk do
  namespace :backup do
    desc 'app backup for release'
    task :exec => :environment do
      filename = backupdir + "/enju_trunk_appbackup_" + Time.now.strftime("%Y%m%d%H%M%S") + ".tar.gz"
      # backup
      sh "cd #{opt_dir}; tar zcvf #{filename} enju_trunk"

    end
  end
end
