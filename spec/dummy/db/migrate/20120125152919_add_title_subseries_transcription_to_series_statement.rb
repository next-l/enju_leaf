class AddTitleSubseriesTranscriptionToSeriesStatement < ActiveRecord::Migration
  def change
    add_column :series_statements, :title_subseries_transcription, :text

  end
end
