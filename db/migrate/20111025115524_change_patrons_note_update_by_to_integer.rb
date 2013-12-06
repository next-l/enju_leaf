class ChangePatronsNoteUpdateByToInteger < ActiveRecord::Migration
  def self.up
    change_column :patrons, :note_update_by, :string
  end

  def self.down
    change_column :patrons, :note_update_by, :integer
  end
end
