class AddEmailToLibraryGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :library_groups, :email, :string, index: {unique: true}, null: false
  end
end
