class AddPictureWidthToPictureFile < ActiveRecord::Migration
  def change
    add_column :picture_files, :picture_width, :integer
    add_column :picture_files, :picture_height, :integer
  end
end
