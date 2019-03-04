class CreateResourceImportFileTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_import_file_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :resource_import_file, index: false, type: :uuid
      t.timestamps
    end

    add_index :resource_import_file_transitions, :resource_import_file_id, name: "index_resource_import_file_transitions_on_file_id"
    add_index :resource_import_file_transitions, [:sort_key, :resource_import_file_id], unique: true, name: "index_resource_import_file_transitions_on_sort_key_and_file_id"
  end
end
