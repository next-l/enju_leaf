class UserExportFileQueue
  @queue = :enju_leaf

  def self.perform(user_export_id)
    UserExportFile.find(user_export_id).export!
  end
end
