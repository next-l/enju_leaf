class AddUserIdToLibraryGroup < ActiveRecord::Migration
  def change
    add_reference :library_groups, :user, index: true, foreign_key: true
  end
end
