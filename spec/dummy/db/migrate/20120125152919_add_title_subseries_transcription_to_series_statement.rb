class AddTitleSubseriesTranscriptionToSeriesStatement < ActiveRecord::Migration[5.2]
  def change
    add_column :series_statements, :title_subseries_transcription, :text

  end
end
