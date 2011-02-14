class AddFileHasToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :file_hash, :string
  end

  def self.down
    remove_column :manifestations, :file_hash
  end
end
