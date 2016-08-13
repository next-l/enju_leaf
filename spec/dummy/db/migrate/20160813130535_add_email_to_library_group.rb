class AddEmailToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :email, :string
  end
end
