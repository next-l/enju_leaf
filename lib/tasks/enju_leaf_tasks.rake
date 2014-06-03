require 'active_record/fixtures'
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

  desc "create initial index"
  task :create_initial_index => :environment do
    Library.reindex
    Shelf.reindex
    User.reindex

    puts 'indexing completed.'
  end

  desc "import users from a TSV file"
  task :user_import => :environment do
    UserImportFile.import
  end
end
