class AddAttachmentsPictureToPictureFile < ActiveRecord::Migration[5.2]
  def self.up
    add_column :picture_files, :picture_file_name, :string
    add_column :picture_files, :picture_content_type, :string
    add_column :picture_files, :picture_file_size, :integer
    add_column :picture_files, :picture_updated_at, :datetime
  end

  def self.down
    remove_column :picture_files, :picture_file_name
    remove_column :picture_files, :picture_content_type
    remove_column :picture_files, :picture_file_size
    remove_column :picture_files, :picture_updated_at
  end
end
