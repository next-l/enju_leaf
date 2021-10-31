class EventExportFileJob < ApplicationJob
  queue_as :enju_leaf

  def perform(event_export_file)
    event_export_file.export!
  end
end
