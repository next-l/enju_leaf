package_dir = "/home/enju/jma/pack/"
packprefix = "enju_jma"

namespace :enju_trunk do
  namespace :pack do
    desc 'Initial packing'
    task :init => :environment do
    end

    desc 'Packaging for staging server'
    task :staging => :environment do
      root = "#{::Rails.root}"
      archives = "Gemfile Gemfile.lock Guardfile Rakefile app/ config/ config.ru db/ lib/ public/ report/ script/ spec/ vendor/fonts vendor/plugins/"

      package_name = "#{packprefix}_pack_staging_#{Time.now.strftime('%Y%m%d%H%M%S')}.tar.bz2"
      #package_dir = "/home/enju/jma/pack/"
      packagefile = "#{package_dir}#{package_name}"
      sh "cd #{::Rails.root}; bundle package"
      sh "cd #{::Rails.root}; tar cjvf #{packagefile} #{archives}"
    end
  end
end
