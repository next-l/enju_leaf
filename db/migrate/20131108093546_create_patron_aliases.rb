class CreatePatronAliases < ActiveRecord::Migration
  def change
    create_table :patron_aliases do |t|
      t.references :patron
      t.string :full_name
      t.string :full_name_transcription
      t.string :full_name_alternative

      t.timestamps
    end 
    add_index :patron_aliases, :patron_id
  end
end
