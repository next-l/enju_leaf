class AddPictureWidthToPictureFile < ActiveRecord::Migration[4.2]
  def change
    add_column :picture_files, :picture_width, :integer
    add_column :picture_files, :picture_height, :integer
  end
end
