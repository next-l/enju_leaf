require 'active_record/fixtures'
require 'tasks/agent_type'
require 'tasks/carrier_type'
require 'tasks/content_type'
require 'tasks/identifier_type'
require 'tasks/item'

namespace :enju_biblio do
  desc "create initial records for enju_biblio"
  task setup: :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_biblio/*.yml').each do |file|
      ActiveRecord::FixtureSet.create_fixtures('db/fixtures/enju_biblio', File.basename(file, '.*'))
    end
    update_carrier_type
  end

  desc "import manifestations and items from a TSV file"
  task resource_import: :environment do
    ResourceImportFile.import
  end

  desc "import manifestations and items from a TSV file"
  task agent_import: :environment do
    AgentImportFile.import
  end

  desc "upgrade enju_biblio"
  task upgrade: :environment do
    Rake::Task['statesman:backfill_most_recent'].invoke('AgentImportFile')
    Rake::Task['statesman:backfill_most_recent'].invoke('ImportRequest')
    Rake::Task['statesman:backfill_most_recent'].invoke('ResourceExportFile')
    Rake::Task['statesman:backfill_most_recent'].invoke('ResourceImportFile')
    update_carrier_type
    puts 'enju_biblio: The upgrade completed successfully.'
  end
end
