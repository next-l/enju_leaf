class CreateReserveStatHasUsers < ActiveRecord::Migration
  def self.up
    create_table :reserve_stat_has_users do |t|
      t.integer :user_reserve_stat_id, null: false
      t.integer :user_id, null: false
      t.integer :reserves_count

      t.timestamps
    end
    add_index :reserve_stat_has_users, :user_reserve_stat_id
    add_index :reserve_stat_has_users, :user_id
  end

  def self.down
    drop_table :reserve_stat_has_users
  end
end
