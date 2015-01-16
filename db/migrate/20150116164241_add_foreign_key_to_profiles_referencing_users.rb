class AddForeignKeyToProfilesReferencingUsers < ActiveRecord::Migration
  def change
    add_foreign_key :profiles, :users, on_delete: :nullify
  end
end
