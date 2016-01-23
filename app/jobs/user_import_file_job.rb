class UserImportFileJob < ActiveJob::Base
  queue_as :enju_leaf

  def perform(user_import_file)
    user_import_file.import_start
  end
end
