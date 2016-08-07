class AddFullNameTranscriptionToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :full_name_transcription, :text
  end
end
