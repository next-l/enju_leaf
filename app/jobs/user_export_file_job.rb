class UserExportFileJob < ApplicationJob
  queue_as :enju_leaf

  def perform(user_export_file)
    user_export_file.export!
  end
end
