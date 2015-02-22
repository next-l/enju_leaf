class CreateMessageTransitions < ActiveRecord::Migration
  def change
    create_table :message_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :message_id
      t.timestamps
    end

    add_index :message_transitions, :message_id
    add_index :message_transitions, [:sort_key, :message_id], unique: true
  end
end
