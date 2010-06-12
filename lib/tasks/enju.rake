require 'rake'
require 'active_record/fixtures'
#require 'action_controller/integration'

namespace :enju do
  desc 'Load initial database fixtures.'
  task :setup do
    require "#{File.dirname(__FILE__)}/../../config/environment.rb"
    if User.administrators.blank?
      puts 'Loading fixtures...'
      Dir.glob(Rails.root.to_s + '/db/fixtures/*.yml').each do |file|
        Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
      end
      unless solr = Sunspot.commit rescue nil
 	      raise "Solr is not running."
      end

      Patron.reindex
      Library.reindex
      puts 'Inititalized successfully.'
    else
      puts 'It seems that you have imported initial data.'
    end
  end
end
