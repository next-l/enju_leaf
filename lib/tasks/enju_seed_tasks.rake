namespace :enju_seed do
  desc "create initial records for enju_seed"
  task setup: :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_seed/*.yml').each do |file|
      ActiveRecord::FixtureSet.create_fixtures('db/fixtures/enju_seed', File.basename(file, '.*'))
    end
  end
end
