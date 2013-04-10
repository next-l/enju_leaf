require 'active_record/fixtures'
desc "create initial records for enju_leaf"
namespace :enju_leaf do
  task :setup => :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_leaf/*.yml').each do |file|
      ActiveRecord::Fixtures.create_fixtures('db/fixtures/enju_leaf', File.basename(file, '.*'))
    end

    Rake::Task['enju_biblio:setup'].invoke
    Rake::Task['enju_library:setup'].invoke

    puts 'initial fixture files loaded.'
  end
end
