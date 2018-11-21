class AddAttachmentDataToContentType < ActiveRecord::Migration[5.1]
  def change
    add_column :content_types, :attachment_data, :jsonb
  end
end
