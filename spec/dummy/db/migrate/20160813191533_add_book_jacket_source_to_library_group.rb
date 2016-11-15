class AddBookJacketSourceToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :book_jacket_source, :string
  end
end
