class AddNoteUpdateLibraryToPatrons < ActiveRecord::Migration
  def self.up
    add_column :patrons, :note_update_library, :string
  end

  def self.down
    remove_column :patrons, :note_update_library
  end
end
