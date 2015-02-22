class CreateUserCheckoutStatTransitions < ActiveRecord::Migration
  def change
    create_table :user_checkout_stat_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :user_checkout_stat_id
      t.timestamps
    end

    add_index :user_checkout_stat_transitions, :user_checkout_stat_id
    add_index :user_checkout_stat_transitions, [:sort_key, :user_checkout_stat_id], unique: true, name: "index_user_checkout_stat_transitions_on_sort_key_and_stat_id"
  end
end
