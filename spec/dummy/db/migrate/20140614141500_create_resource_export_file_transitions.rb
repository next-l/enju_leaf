class CreateResourceExportFileTransitions < ActiveRecord::Migration[5.1]
  def change
    create_table :resource_export_file_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.integer :resource_export_file_id
      t.timestamps
    end

    add_index :resource_export_file_transitions, :resource_export_file_id, name: "index_resource_export_file_transitions_on_file_id"
    add_index :resource_export_file_transitions, [:sort_key, :resource_export_file_id], unique: true, name: "index_resource_export_file_transitions_on_sort_key_and_file_id"
  end
end
