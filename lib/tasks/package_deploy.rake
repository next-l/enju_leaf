package_dir = "/home/enju/customer/pack/"
packprefix = "enju_production"
root = "#{::Rails.root}"

def packing(packagefile, archives, excludes = "")
  #sh "cd #{::Rails.root}; bundle package --all"
  sh "cd #{::Rails.root}; tar cjvf #{packagefile} #{archives} --exclude #{excludes}"
end

namespace :enju_trunk do
  namespace :pack do
    desc 'Initial packing'
    task :init => :environment do
      sh "cd #{::Rails.root}; git log -1 > GitLastLog"

      archives = "Gemfile Gemfile.lock GitLastLog Rakefile app/ config/ config.ru db/ lib/ public/ report/ script/ solr/ spec/ vendor/fonts vendor/cache/ vendor/assets/ report/" 

      #package_name = "#{packprefix}_pack_staging_init_#{Time.now.strftime('%Y%m%d%H%M%S')}.tar.bz2"
      package_name = "#{packprefix}_pack_staging_init.tar.bz2"
      packagefile = "#{package_dir}#{package_name}"
      #excludes = ".gitkeep *.sample"
      exclude_from = "script/exclude_init"
     
      #packing
      sh "cd #{::Rails.root}; tar cjvf #{packagefile} #{archives} -X #{exclude_from}"
    end

    desc 'Packaging for staging server'
    task :staging => :environment do
      sh "cd #{::Rails.root}; git log -1 > GitLastLog"
      archives = "Gemfile Gemfile.lock GitLastLog Rakefile app/ db/fixtures/ solr/conf/ config/locales/ config/routes.rb db/ lib/ public/ script/ vendor/fonts vendor/cache/ report/ config/initializers/thinreports.rb"
      excludes = "*.sample"

      package_name = "#{packprefix}_pack_staging_#{Time.now.strftime('%Y%m%d%H%M%S')}.tar.bz2"
      packagefile = "#{package_dir}#{package_name}"

      exclude_from = "script/exclude_init"
      sh "cd #{::Rails.root}; tar cjvf #{packagefile} #{archives} -X #{exclude_from}"
    end
  end
end
