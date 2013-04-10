class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.datetime :deleted_at
      t.integer :library_id, :default => 1, :null => false
      t.integer :user_group_id, :default => 1, :null => false
      t.datetime :expired_at
      t.integer :required_role_id, :integer, :default => 1, :null => false
      t.text :note
      t.text :keyword_list
      t.string :user_number
      t.string :state
      t.string :locale

      t.timestamps
    end

    add_index :users, :username, :unique => true
    add_index :users, :user_group_id
    add_index :users, :user_number, :unique => true
  end
end
