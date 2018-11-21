class AddAttachmentDataToResourceImportFile < ActiveRecord::Migration[5.1]
  def change
    add_column :resource_import_files, :attachment_data, :jsonb
  end
end
