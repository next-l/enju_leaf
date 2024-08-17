class CreateUserImportFileTransitions < ActiveRecord::Migration[4.2]
  def change
    create_table :user_import_file_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first.adapter.try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.references :user_import_file, index: true
      t.timestamps
    end

    add_index :user_import_file_transitions, [:sort_key, :user_import_file_id], unique: true, name: "index_user_import_file_transitions_on_sort_key_and_file_id"
  end
end
