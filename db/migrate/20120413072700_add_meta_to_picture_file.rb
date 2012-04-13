class AddMetaToPictureFile < ActiveRecord::Migration
  def change
    add_column :picture_files, :meta, :text
  end
end
