class AddNoteToSeriesStatement < ActiveRecord::Migration[4.2]
  def up
    add_column :series_statements, :note, :text
  end

  def down
    remove_column :series_statements, :note
  end
end
