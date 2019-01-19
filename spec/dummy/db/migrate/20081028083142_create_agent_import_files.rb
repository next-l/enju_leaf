class CreateAgentImportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_import_files do |t|
      t.string :content_type
      t.integer :size
      t.references :user, foreign_key: true
      t.text :note
      t.datetime :executed_at
      t.string :agent_import_file_name
      t.string :agent_import_content_type
      t.integer :agent_import_file_size
      t.datetime :agent_import_updated_at

      t.timestamps
    end
  end
end
