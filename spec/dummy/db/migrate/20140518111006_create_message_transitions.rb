class CreateMessageTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :message_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :message
      t.timestamps
    end

    add_index :message_transitions, [:sort_key, :message_id], unique: true
  end
end
