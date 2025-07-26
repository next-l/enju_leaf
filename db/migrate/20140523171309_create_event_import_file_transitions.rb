class CreateEventImportFileTransitions < ActiveRecord::Migration[4.2]
  def change
    create_table :event_import_file_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first.adapter.try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :event_import_file_id
      t.timestamps
    end

    add_index :event_import_file_transitions, :event_import_file_id
    add_index :event_import_file_transitions, [:sort_key, :event_import_file_id], unique: true, name: "index_event_import_file_transitions_on_sort_key_and_file_id"
  end
end
