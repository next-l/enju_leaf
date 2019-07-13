class CreatePictureFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :picture_files do |t|
      t.integer :picture_attachable_id
      t.string :picture_attachable_type
      t.string :content_type
      t.text :title
      t.string :thumbnail
      t.integer :position

      t.timestamps
    end
    add_index :picture_files, [:picture_attachable_id, :picture_attachable_type], name: "index_picture_files_on_picture_attachable_id_and_type"
  end
end
