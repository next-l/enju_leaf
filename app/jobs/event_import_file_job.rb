class EventImportFileJob < ApplicationJob
  queue_as :enju_leaf

  def perform(event_import_file)
    event_import_file.import_start
  end
end
