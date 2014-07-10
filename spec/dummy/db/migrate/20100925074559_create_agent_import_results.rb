class CreateAgentImportResults < ActiveRecord::Migration
  def change
    create_table :agent_import_results do |t|
      t.integer :agent_import_file_id
      t.integer :agent_id
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end
end
