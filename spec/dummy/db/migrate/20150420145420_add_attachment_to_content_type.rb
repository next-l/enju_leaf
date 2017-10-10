class AddAttachmentToContentType < ActiveRecord::Migration[5.1]
  def change
    add_column :content_types, :attachment_id, :string
    add_column :content_types, :attachment_filename, :string
    add_column :content_types, :attachment_size, :integer
    add_column :content_types, :attachment_content_type, :string
  end
end
