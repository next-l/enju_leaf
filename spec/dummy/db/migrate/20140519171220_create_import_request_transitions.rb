class CreateImportRequestTransitions < ActiveRecord::Migration
  def change
    create_table :import_request_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.jsonb :metadata
      else
        t.jsonb :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :import_request_id
      t.timestamps
    end

    add_index :import_request_transitions, :import_request_id
    add_index :import_request_transitions, [:sort_key, :import_request_id], unique: true, name: "index_import_request_transitions_on_sort_key_and_request_id"
  end
end
