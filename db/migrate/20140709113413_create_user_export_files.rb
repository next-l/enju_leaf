class CreateUserExportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :user_export_files do |t|
      t.references :user, index: true
      t.string :user_export_content_type
      t.string :user_export_file_name
<<<<<<< HEAD
      t.bigint :user_export_file_size
=======
      t.integer :user_export_file_size
>>>>>>> main
      t.datetime :user_export_updated_at
      t.datetime :executed_at

      t.timestamps
    end
  end
end
