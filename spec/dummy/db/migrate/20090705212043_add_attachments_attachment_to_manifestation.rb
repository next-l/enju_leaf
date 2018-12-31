class AddAttachmentsAttachmentToManifestation < ActiveRecord::Migration[4.2]
  def self.up
    add_column :manifestations, :attachment_file_name, :string
    add_column :manifestations, :attachment_content_type, :string
    add_column :manifestations, :attachment_file_size, :integer
    add_column :manifestations, :attachment_updated_at, :datetime
  end

  def self.down
    remove_column :manifestations, :attachment_file_name
    remove_column :manifestations, :attachment_content_type
    remove_column :manifestations, :attachment_file_size
    remove_column :manifestations, :attachment_updated_at
  end
end
