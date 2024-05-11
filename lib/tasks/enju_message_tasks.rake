require 'active_record/fixtures'

namespace :enju_message do
  desc "upgrade enju_message"
  task upgrade: :environment do
    %w(Message).each do |klass|
      Rake::Task['statesman:backfill_most_recent'].invoke(klass)
      Rake::Task['statesman:backfill_most_recent'].reenable
    end

    puts 'enju_message: The upgrade completed successfully.'
  end
end
