class AddBookJacketSourceToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :library_groups, :book_jacket_source, :string
  end
end
