class ResourceImportFileJob < ApplicationJob
  queue_as :enju_leaf

  def perform(resource_import_file)
    resource_import_file.import_start
  end
end
