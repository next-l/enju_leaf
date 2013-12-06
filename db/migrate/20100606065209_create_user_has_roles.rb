class CreateUserHasRoles < ActiveRecord::Migration
  def self.up
    create_table :user_has_roles do |t|
      t.integer :user_id
      t.integer :role_id

      t.timestamps
    end
    add_index :user_has_roles, :user_id
    add_index :user_has_roles, :role_id
  end

  def self.down
    drop_table :user_has_roles
  end
end
