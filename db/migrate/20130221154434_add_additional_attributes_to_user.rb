class AddAdditionalAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :user_number, :string
    add_column :users, :state, :string
    add_column :users, :locale, :string
    add_column :users, :deleted_at, :datetime
    add_column :users, :expired_at, :datetime
    add_column :users, :library_id, :integer, :default => 1, :null => false
    add_column :users, :required_role_id, :integer, :default => 1, :null => false
    add_column :users, :user_group_id, :integer, :default => 1, :null => false
    add_column :users, :note, :text
    add_column :users, :keyword_list, :text

    add_column :users, :failed_attempts, :integer, :default => 0
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime

    add_column :users, :confirmed_at, :datetime

    add_index :users, :username, :unique => true
    add_index :users, :user_group_id
    add_index :users, :user_number, :unique => true
    add_index :users, :unlock_token,         :unique => true
  end
end
