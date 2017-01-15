class CreateUserCheckoutStatTransitions < ActiveRecord::Migration
  def change
    create_table :user_checkout_stat_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :user_checkout_stat_id, null: false
      t.timestamps null: false
    end

    add_index :user_checkout_stat_transitions, :user_checkout_stat_id
    add_index :user_checkout_stat_transitions, [:sort_key, :user_checkout_stat_id], unique: true, name: 'index_user_checkout_stat_transitions_on_sort_key_and_stat_id'
  end
end
