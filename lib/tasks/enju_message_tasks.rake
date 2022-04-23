require 'active_record/fixtures'

namespace :enju_message do
  desc "upgrade enju_message"
  task upgrade: :environment do
    Rake::Task['statesman:backfill_most_recent'].invoke('Message')
    puts 'enju_message: The upgrade completed successfully.'
  end
end
