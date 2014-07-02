class UserImportFileQueue
  @queue = :user_import_file

  def self.perform(user_import_file_id)
    UserImportFile.find(user_import_file_id).import_start
  end
end
