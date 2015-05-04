class UserImportFileQueue
  @queue = :enju_leaf

  def self.perform(user_import_file_id)
    UserImportFile.find(user_import_file_id).import_start
  end
end
