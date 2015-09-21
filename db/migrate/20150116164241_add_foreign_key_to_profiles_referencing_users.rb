class AddForeignKeyToProfilesReferencingUsers < ActiveRecord::Migration
  def change
    add_foreign_key :profiles, :users
    add_foreign_key :profiles, :user_groups
  end
end
