class AddColumnToManifestations < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :edition_display_value, :string
    add_column :manifestations, :other_number_list, :string
  end

  def self.down
    remove_column :manifestations, :edition_display_value
    remove_column :manifestations, :other_number_list
  end
end
