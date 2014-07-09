class CreateUserExportFileTransitions < ActiveRecord::Migration
  def change
    create_table :user_export_file_transitions do |t|
      t.string :to_state
      t.text :metadata, default: "{}"
      t.integer :sort_key
      t.integer :user_export_file_id
      t.timestamps
    end

    add_index :user_export_file_transitions, :user_export_file_id, name: "index_user_export_file_transitions_on_file_id"
    add_index :user_export_file_transitions, [:sort_key, :user_export_file_id], unique: true, name: "index_user_export_file_transitions_on_sort_key_and_file_id"
  end
end
