class CreatePictureFiles < ActiveRecord::Migration
  def self.up
    create_table :picture_files do |t|
      t.integer :picture_attachable_id
      t.string :picture_attachable_type
      t.integer :size
      t.string :content_type
      t.text :title
      t.text :filename
      t.integer :height
      t.integer :width
      t.string :thumbnail
      t.string :file_hash
      t.integer :position

      t.timestamps
    end
    add_index :picture_files, [:picture_attachable_id, :picture_attachable_type], :name => "index_picture_files_on_picture_attachable_id_and_type"
  end

  def self.down
    drop_table :picture_files
  end
end
