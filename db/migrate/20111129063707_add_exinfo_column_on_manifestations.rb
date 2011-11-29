class AddExinfoColumnOnManifestations < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :exinfo_1, :string
    add_column :manifestations, :exinfo_2, :string
    add_column :manifestations, :exinfo_3, :string
    add_column :manifestations, :exinfo_4, :string
    add_column :manifestations, :exinfo_5, :string
  end

  def self.down
    remove_column :manifestations, :exinfo_1
    remove_column :manifestations, :exinfo_2
    remove_column :manifestations, :exinfo_3
    remove_column :manifestations, :exinfo_4
    remove_column :manifestations, :exinfo_5
  end
end
