class AddAttachmentDataToResourceExportFile < ActiveRecord::Migration[5.1]
  def change
    add_column :resource_export_files, :attachment_data, :jsonb
  end
end
