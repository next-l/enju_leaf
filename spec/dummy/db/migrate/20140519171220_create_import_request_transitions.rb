class CreateImportRequestTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :import_request_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :import_request
      t.timestamps
    end

    add_index :import_request_transitions, [:sort_key, :import_request_id], unique: true, name: "index_import_request_transitions_on_sort_key_and_request_id"
  end
end
