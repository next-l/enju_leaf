class CreateResourceExportFileTransitions < ActiveRecord::Migration
  def change
    create_table :resource_export_file_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.jsonb :metadata
      else
        t.jsonb :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :resource_export_file_id
      t.timestamps
    end

    add_index :resource_export_file_transitions, :resource_export_file_id, name: "index_resource_export_file_transitions_on_file_id"
    add_index :resource_export_file_transitions, [:sort_key, :resource_export_file_id], unique: true, name: "index_resource_export_file_transitions_on_sort_key_and_file_id"
  end
end
