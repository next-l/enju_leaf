class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
      t.string :authentication_token
      #t.encryptable

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
    #add_index :users, :remember_token,         :unique => true

    # メールアドレスを持っていない利用者が存在するため
    change_column :users, :email, :string, :null => true
  end

  def self.down
    drop_table :users
  end
end
