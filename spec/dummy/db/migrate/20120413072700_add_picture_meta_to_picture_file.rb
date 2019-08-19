class AddPictureMetaToPictureFile < ActiveRecord::Migration[5.2]
  def change
    add_column :picture_files, :picture_meta, :text
  end
end
