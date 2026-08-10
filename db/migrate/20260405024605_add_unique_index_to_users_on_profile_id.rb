class AddUniqueIndexToUsersOnProfileId < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :profile_id
    add_index :users, :profile_id, unique: true
  end
end
