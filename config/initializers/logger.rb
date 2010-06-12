# http://robaldred.co.uk/2009/01/custom-log-files-for-your-ruby-on-rails-applications/
class SearchLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end

SEARCH_LOG_FILE_NAME = 'search.log'
search_log = File.open(File.join(Rails.root, 'log', SEARCH_LOG_FILE_NAME), 'a')
search_log.sync = true
SEARCH_LOGGER = Logger.new(search_log)
