class AddUniqueIndexToLibrariesOnName < ActiveRecord::Migration[6.1]
  def change
    add_index :libraries, :name, unique: true
    add_index :libraries, :isil, unique: true, where: "isil != '' AND isil IS NOT NULL"
  end
end
