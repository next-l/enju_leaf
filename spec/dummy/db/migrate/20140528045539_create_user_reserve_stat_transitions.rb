class CreateUserReserveStatTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_reserve_stat_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :user_reserve_stat
      t.timestamps
    end

    add_index :user_reserve_stat_transitions, [:sort_key, :user_reserve_stat_id], unique: true, name: "index_user_reserve_stat_transitions_on_sort_key_and_stat_id"
  end
end
