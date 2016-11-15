class AddImageDataToPictureFile < ActiveRecord::Migration[5.0]
  def change
    add_column :picture_files, :image_data, :jsonb
  end
end
