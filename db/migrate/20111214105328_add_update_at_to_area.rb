class AddUpdateAtToArea < ActiveRecord::Migration
  def self.up
    add_column :areas, :created_at, :timestamp
    add_column :areas, :updated_at, :timestamp
  end

  def self.down
    remove_column :areas, :created_at
    remove_column :areas, :updated_at
  end
end
