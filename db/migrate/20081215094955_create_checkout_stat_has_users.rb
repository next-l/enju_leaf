class CreateCheckoutStatHasUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :checkout_stat_has_users do |t|
      t.references :user_checkout_stat, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :checkouts_count, default: 0, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :checkout_stat_has_users
  end
end
