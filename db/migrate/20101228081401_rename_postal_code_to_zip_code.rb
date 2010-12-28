class RenamePostalCodeToZipCode < ActiveRecord::Migration
  def self.up
    remove_column :patrons, :postal_code
    rename_column :libraries, :postal_code, :zip_code
  end

  def self.down
    add_column :patrons, :postal_code, :string
    rename_column :libraries, :zip_code, :postal_code
  end
end
