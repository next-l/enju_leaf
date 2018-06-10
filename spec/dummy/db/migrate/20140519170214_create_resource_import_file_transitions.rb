class CreateResourceImportFileTransitions < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_import_file_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :resource_import_file_id
      t.timestamps
    end

    add_index :resource_import_file_transitions, :resource_import_file_id, name: "index_resource_import_file_transitions_on_file_id"
    add_index :resource_import_file_transitions, [:sort_key, :resource_import_file_id], unique: true, name: "index_resource_import_file_transitions_on_sort_key_and_file_id"
  end
end
