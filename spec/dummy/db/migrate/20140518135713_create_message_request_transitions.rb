class CreateMessageRequestTransitions < ActiveRecord::Migration[4.2]
  def change
    create_table :message_request_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :message_request_id
      t.timestamps
    end

    add_index :message_request_transitions, :message_request_id
    add_index :message_request_transitions, [:sort_key, :message_request_id], unique: true, name: "index_message_request_transitions_on_sort_key_and_request_id"
  end
end
