class AddDcndlSchema < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :title_alternative_transcription, :text
    add_column :agents, :full_name_alternative_transcription, :text
    add_column :manifestations, :description, :text
    add_column :manifestations, :abstract, :text
    add_column :manifestations, :available_at, :timestamp
    add_column :manifestations, :valid_until, :timestamp
    add_column :manifestations, :date_submitted, :timestamp
    add_column :manifestations, :date_accepted, :timestamp
    add_column :manifestations, :date_caputured, :timestamp
    rename_column :manifestations, :copyright_date, :date_copyrighted
  end

  def self.down
    remove_column :manifestations, :title_alternative_transcription
    remove_column :agents, :full_name_alternative_transcription
    remove_column :manifestations, :description
    remove_column :manifestations, :abstract
    remove_column :manifestations, :available_at
    remove_column :manifestations, :valid_until
    remove_column :manifestations, :date_submitted
    remove_column :manifestations, :date_accepted
    remove_column :manifestations, :date_caputured
    rename_column :manifestations, :date_copyrighted, :copyright_date
  end
end
