class AddIndexToUserHasRolesOnUserIdAndRoleId < ActiveRecord::Migration[6.1]
  def change
    remove_index :user_has_roles, :user_id
    add_index :user_has_roles, [:user_id, :role_id], unique: true
  end
end
