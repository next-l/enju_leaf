class AddRecentOnManifestations < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :except_recent, :boolean, :default => :false
  end

  def self.down
    remove_column :manifestations, :recent
  end
end
