class RemoveUserIdFromLibraryGroups < ActiveRecord::Migration[7.1]
  def change
    remove_column :library_groups, :user_id, :bigint
  end
end
