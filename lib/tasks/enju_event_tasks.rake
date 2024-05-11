require 'active_record/fixtures'
desc "create initial records for enju_event"
namespace :enju_event do
  task setup: :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_event/*.yml').each do |file|
      ActiveRecord::FixtureSet.create_fixtures('db/fixtures/enju_event', File.basename(file, '.*'))
    end
  end

  desc "import events from a TSV file"
  task event_import: :environment do
    EventImportFile.import
  end

  desc "upgrade enju_circulation"
  task upgrade: :environment do
    %w(EventExportFile EventImportFile).each do |klass|
      Rake::Task['statesman:backfill_most_recent'].invoke(klass)
      Rake::Task['statesman:backfill_most_recent'].reenable
    end
  end
end
