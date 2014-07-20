class CreateBookmarkStatTransitions < ActiveRecord::Migration
  def change
    create_table :bookmark_stat_transitions do |t|
      t.string :to_state
      t.text :metadata, default: "{}"
      t.integer :sort_key
      t.integer :bookmark_stat_id
      t.timestamps
    end

    add_index :bookmark_stat_transitions, :bookmark_stat_id
    add_index :bookmark_stat_transitions, [:sort_key, :bookmark_stat_id], unique: true, name: "index_bookmark_stat_transitions_on_sort_key_and_stat_id"
  end
end
