class AddForeignKeyToProfilesReferencingUsers < ActiveRecord::Migration
  def change
    add_foreign_key :profiles, :users, on_delete: :nullify
    add_foreign_key :profiles, :libraries
    add_foreign_key :profiles, :user_groups
  end
end
