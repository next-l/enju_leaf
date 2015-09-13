class AddPictureIdToPictureFile < ActiveRecord::Migration
  def change
    add_column :picture_files, :picture_id, :string
    add_index :picture_files, :picture_id
  end
end
