class UserExportFileJob < ActiveJob::Base
  queue_as :default

  def perform(user_export_file)
    user_export_file.export!
  end
end
