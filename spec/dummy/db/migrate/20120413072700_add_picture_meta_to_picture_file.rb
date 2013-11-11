class AddPictureMetaToPictureFile < ActiveRecord::Migration
  def change
    add_column :picture_files, :picture_meta, :text
  end
end
