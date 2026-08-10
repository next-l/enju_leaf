class AddAttachmentsPictureToPictureFile < ActiveRecord::Migration[4.2]
  def up
    add_column :picture_files, :picture_file_name, :string
    add_column :picture_files, :picture_content_type, :string
    add_column :picture_files, :picture_file_size, :integer
    add_column :picture_files, :picture_updated_at, :datetime
  end

  def down
    remove_column :picture_files, :picture_file_name
    remove_column :picture_files, :picture_content_type
    remove_column :picture_files, :picture_file_size
    remove_column :picture_files, :picture_updated_at
  end
end
