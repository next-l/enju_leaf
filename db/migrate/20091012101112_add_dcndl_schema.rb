class AddDcndlSchema < ActiveRecord::Migration
  def self.up
    add_column :resources, :title_alternative_transcription, :text
    add_column :patrons, :full_name_alternative_transcription, :text
    add_column :resources, :description, :text
    add_column :resources, :abstract, :text
    add_column :resources, :available_at, :timestamp
    add_column :resources, :valid_until, :timestamp
    add_column :resources, :date_submitted, :timestamp
    add_column :resources, :date_accepted, :timestamp
    add_column :resources, :date_caputured, :timestamp
    rename_column :resources, :copyright_date, :date_copyrighted
  end

  def self.down
    remove_column :resources, :title_alternative_transcription
    remove_column :patrons, :full_name_alternative_transcription
    remove_column :resources, :description
    remove_column :resources, :abstract
    remove_column :resources, :available_at
    remove_column :resources, :valid_until
    remove_column :resources, :date_submitted
    remove_column :resources, :date_accepted
    remove_column :resources, :date_caputured
    rename_column :resources, :date_copyrighted, :copyright_date
  end
end
