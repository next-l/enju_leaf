require 'active_record/fixtures'
require 'tasks/subject_type'
require 'tasks/subject_heading_type'

desc "create initial records for enju_subject"
namespace :enju_subject do
  task setup: :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_subject/*.yml').each do |file|
      ActiveRecord::FixtureSet.create_fixtures('db/fixtures/enju_subject', File.basename(file, '.*'))
    end

    puts 'initial fixture files loaded.'
  end

  #desc "upgrade enju_subject"
  #task :upgrade => :environment do
  #  puts 'enju_subject: The upgrade completed successfully.'
  #end
end
