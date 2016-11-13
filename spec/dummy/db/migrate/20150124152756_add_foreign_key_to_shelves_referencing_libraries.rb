class AddForeignKeyToShelvesReferencingLibraries < ActiveRecord::Migration
  def change
    add_foreign_key :shelves, :libraries
    add_foreign_key :items, :shelves
  end
end
