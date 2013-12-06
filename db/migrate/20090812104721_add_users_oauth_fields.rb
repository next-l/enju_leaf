class AddUsersOauthFields < ActiveRecord::Migration
  def self.up
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_secret, :string
    add_index :users, :oauth_token, :unique => true
    add_index :users, :oauth_secret, :unique => true
  end

  def self.down
    remove_column :users, :oauth_token
    remove_column :users, :oauth_secret
  end
end
