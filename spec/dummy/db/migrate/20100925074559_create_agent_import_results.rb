class CreateAgentImportResults < ActiveRecord::Migration[4.2]
  def change
    create_table :agent_import_results do |t|
      t.integer :agent_import_file_id
      t.integer :agent_id
      t.text :body

      t.timestamps
    end
  end
end
