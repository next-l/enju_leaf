class UserImportJob < ActiveJob::Base
  queue_as :default

  def perform(user_import_file)
    user_import_file.import_start
  end
end
