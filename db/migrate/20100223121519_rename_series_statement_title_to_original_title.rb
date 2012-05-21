class RenameSeriesStatementTitleToOriginalTitle < ActiveRecord::Migration
  def self.up
    rename_column :series_statements, :title, :original_title
    add_column :series_statements, :title_transcription, :text
    add_column :series_statements, :title_alternative, :text
  end

  def self.down
    rename_column :series_statements, :original_title, :title
    remove_column :series_statements, :title_transcription
    remove_column :series_statements, :title_alternative
  end
end
