class AddRecentOnManifestations < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :except_recent, :boolean, :default => :false
    Manifestation.reset_column_information
    Manifestation.update_all ["except_recent = ?", false]
  end

  def self.down
    remove_column :manifestations, :except_recent
  end
end
