class AddForeignKeyToProfilesReferencingUsers < ActiveRecord::Migration
  def change
    add_foreign_key :profiles, :users, on_delete: :nullify
    add_foreign_key :profiles, :library
    add_foreign_key :profiles, :user_group
  end
end
