class CreateAgentImportFileTransitions < ActiveRecord::Migration
  def change
    create_table :agent_import_file_transitions do |t|
      t.string :to_state
      t.text :metadata, default: "{}"
      t.integer :sort_key
      t.integer :agent_import_file_id
      t.timestamps
    end

    add_index :agent_import_file_transitions, :agent_import_file_id
    add_index :agent_import_file_transitions, [:sort_key, :agent_import_file_id], unique: true, name: "index_agent_import_file_transitions_on_sort_key_and_file_id"
  end
end
