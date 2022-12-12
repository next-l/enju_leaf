class CreateAgentImportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :agent_import_files do |t|
      t.integer :parent_id
      t.integer :user_id
      t.text :note
      t.datetime :executed_at

      t.timestamps
    end
    add_index :agent_import_files, :parent_id
    add_index :agent_import_files, :user_id
  end
end
