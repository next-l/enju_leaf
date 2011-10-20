class AddColumnForUpdateOnPatrons < ActiveRecord::Migration
  def self.up
    add_column :patrons, :note_update_at, :timestamp
    add_column :patrons, :note_update_by, :integer
  end

  def self.down
    remove_column :patrons, :note_update_at
    remove_column :patrons, :note_update_by
  end
end
