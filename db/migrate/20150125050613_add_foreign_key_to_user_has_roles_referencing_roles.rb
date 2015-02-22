class AddForeignKeyToUserHasRolesReferencingRoles < ActiveRecord::Migration
  def change
    add_foreign_key :user_has_roles, :roles
  end
end
