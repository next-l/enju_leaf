class AddUniqueIndexToLibrariesOnName < ActiveRecord::Migration[6.1]
  def change
    add_index :libraries, :name, unique: true
  end
end
