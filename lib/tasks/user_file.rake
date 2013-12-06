namespace :enju do
  namespace :user_file do
    desc 'cleanup expired user files'
    task :cleanup => :environment do
      UserFile.cleanup!
    end
  end
end
