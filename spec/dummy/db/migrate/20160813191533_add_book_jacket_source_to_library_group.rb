class AddBookJacketSourceToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :book_jacket_source, :string
  end
end
