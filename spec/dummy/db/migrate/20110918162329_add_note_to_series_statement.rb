class AddNoteToSeriesStatement < ActiveRecord::Migration[5.1]
  def self.up
    add_column :series_statements, :note, :text
  end

  def self.down
    remove_column :series_statements, :note
  end
end
