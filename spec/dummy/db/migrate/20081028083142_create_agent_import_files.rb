class CreateAgentImportFiles < ActiveRecord::Migration
  def change
    create_table :agent_import_files do |t|
      t.integer :parent_id
      t.string :content_type
      t.integer :size
      t.integer :user_id
      t.text :note
      t.datetime :executed_at
      t.string :agent_import_file_name
      t.string :agent_import_content_type
      t.integer :agent_import_file_size
      t.datetime :agent_import_updated_at

      t.timestamps
    end
    add_index :agent_import_files, :parent_id
    add_index :agent_import_files, :user_id
  end
end
