class CreateMessageRequestTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :message_request_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :message_request
      t.timestamps
    end

    add_index :message_request_transitions, [:sort_key, :message_request_id], unique: true, name: "index_message_request_transitions_on_sort_key_and_request_id"
  end
end
