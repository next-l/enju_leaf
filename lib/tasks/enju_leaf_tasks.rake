require 'active_record/fixtures'
require 'tasks/profile'

namespace :enju_leaf do
  desc "create initial records for enju_leaf"
  task :setup => :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_leaf/*.yml').each do |file|
      ActiveRecord::Fixtures.create_fixtures('db/fixtures/enju_leaf', File.basename(file, '.*'))
    end

    Rake::Task['enju_biblio:setup'].invoke
    Rake::Task['enju_library:setup'].invoke

    puts 'initial fixture files loaded.'
  end

  desc "import users from a TSV file"
  task :user_import => :environment do
    UserImportFile.import
  end

  desc "upgrade enju_leaf"
  task :upgrade => :environment do
    Rake::Task['enju_biblio:upgrade'].invoke
    Rake::Task['enju_circulation:upgrade'].invoke
    Rake::Task['enju_library:upgrade'].invoke
    Rake::Task['enju_message:upgrade'].invoke
    Rake::Task['enju_subject:upgrade'].invoke
    Profile.transaction do
      update_profile
    end
    puts 'enju_leaf: The upgrade completed successfully.'
  end

  desc "reindex all models"
  task :reindex, [:batch_size, :models, :silence] => :environment do |t, args|
    Rails::Engine.subclasses.each{|engine| engine.instance.eager_load!}
    Rake::Task['sunspot:reindex'].execute(args)
  end
end
