class AddEnjuAccessKeyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :enju_access_key, :string
    add_index :users, :enju_access_key, :unique => true
  end

  def self.down
    remove_column :users, :enju_access_key
  end
end
