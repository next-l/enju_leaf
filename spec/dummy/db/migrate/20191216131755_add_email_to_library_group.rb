class AddEmailToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :email, :string
    add_index :library_groups, :email
  end
end
