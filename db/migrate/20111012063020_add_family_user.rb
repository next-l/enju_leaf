class AddFamilyUser < ActiveRecord::Migration
  def self.up
    create_table :family_users do |t|
      t.integer :family_id
      t.integer :user_id
      t.timestamps
    end    
    add_index :family_users, :family_id
    add_index :family_users, :user_id
  end

  def self.down
      drop_table :family_users
  end
end
