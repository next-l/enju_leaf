class AddAttachmentDataToUserImportFile < ActiveRecord::Migration[5.0]
  def change
    add_column :user_import_files, :attachment_data, :jsonb
  end
end
