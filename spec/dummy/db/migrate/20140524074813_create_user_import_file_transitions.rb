class CreateUserImportFileTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_import_file_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :user_import_file
      t.timestamps
    end

    add_index :user_import_file_transitions, [:sort_key, :user_import_file_id], unique: true, name: "index_user_import_file_transitions_on_sort_key_and_file_id"
  end
end
