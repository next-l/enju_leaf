class CreateBookmarkStatTransitions < ActiveRecord::Migration[4.2]
  def up
    create_table :bookmark_stat_transitions, if_not_exists: true do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first.adapter.try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :bookmark_stat_id
      t.timestamps
    end

    add_index :bookmark_stat_transitions, :bookmark_stat_id
    add_index :bookmark_stat_transitions, [:sort_key, :bookmark_stat_id], unique: true, name: "index_bookmark_stat_transitions_on_sort_key_and_stat_id"
  end

  def down
    drop_table :bookmark_stat_transitions
  end
end
