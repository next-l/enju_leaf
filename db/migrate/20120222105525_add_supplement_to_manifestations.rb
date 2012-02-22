class AddSupplementToManifestations < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :supplement, :text
  end

  def self.down
    remove_column :manifestations, :supplement
  end
end
