class CreateUserImportFiles < ActiveRecord::Migration
  def change
    create_table :user_import_files do |t|
      t.integer :user_id
      t.text :note
      t.datetime :executed_at
      t.string :user_import_file_name
      t.string :user_import_content_type
      t.integer :user_import_file_size
      t.datetime :user_import_updated_at
      t.string :user_import_fingerprint
      t.string :edit_mode
      t.text :error_message

      t.timestamps
    end
  end
end
