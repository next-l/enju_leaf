SEARCH_LOG_FILE_NAME = 'search.log'
search_log = File.open(File.join(Rails.root, 'log', SEARCH_LOG_FILE_NAME), 'a')
search_log.sync = true
SEARCH_LOGGER = Logger.new(search_log)
