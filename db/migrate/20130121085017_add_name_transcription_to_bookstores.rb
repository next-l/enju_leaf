class AddNameTranscriptionToBookstores < ActiveRecord::Migration
  def change
    add_column :bookstores, :name_transcription, :string
  end
end
