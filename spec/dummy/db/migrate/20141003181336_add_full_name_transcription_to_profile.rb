class AddFullNameTranscriptionToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :full_name_transcription, :text
  end
end
