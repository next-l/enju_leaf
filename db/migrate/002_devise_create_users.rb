class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.confirmable
      t.recoverable
      t.rememberable :use_salt => false
      t.trackable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable
      t.encryptable

      t.timestamps
      t.datetime :deleted_at

      t.string :username, :null => false
      t.integer :library_id, :default => 1, :null => false
      t.integer :user_group_id, :default => 1, :null => false
      t.integer :reserves_count, :default => 0, :null => false
      t.datetime :expired_at
      t.integer :libraries_count, :default => 0, :null => false
      t.integer :bookmarks_count, :default => 0, :null => false
      t.integer :checkouts_count, :default => 0, :null => false
      t.string :checkout_icalendar_token
      t.integer :questions_count, :default => 0, :null => false
      t.integer :answers_count, :default => 0, :null => false
      t.string :answer_feed_token
      t.integer :due_date_reminder_days, :default => 1, :null => false
      t.text :note
      t.boolean :share_bookmarks, :default => false, :null => false
      t.boolean :save_search_history, :default => false, :null => false
      t.boolean :save_checkout_history, :default => false, :null => false
      t.integer :required_role_id, :default => 1, :null => false
      t.text :keyword_list
      t.string :user_number
      t.string :state
      t.integer :required_score, :default => 0, :null => false
      t.string :locale
    end
    add_index :users, :username, :unique => true
    add_index :users, :user_group_id
    add_index :users, :required_role_id
    add_index :users, :user_number, :unique => true
    add_index :users, :email,                :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :unlock_token,         :unique => true
    add_index :users, :remember_token,         :unique => true

    # メールアドレスを持っていない利用者が存在するため
    change_column :users, :email, :string, :null => true
  end

  def self.down
    drop_table :users
  end
end
