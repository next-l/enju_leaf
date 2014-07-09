class UserExportFileQueue
  @queue = :user_export_file

  def self.perform(user_export_id)
    UserExportFile.find(user_export_id).export!
  end
end
