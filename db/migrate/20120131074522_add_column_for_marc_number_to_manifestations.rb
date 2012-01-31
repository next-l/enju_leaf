class AddColumnForMarcNumberToManifestations < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :marc_number, :string
  end

  def self.down
    remove_column :manifestations, :marc_number
  end
end
