class ResourceExportFileJob < ApplicationJob
  queue_as :enju_leaf

  def perform(resource_export_file)
    resource_export_file.export!
  end
end
