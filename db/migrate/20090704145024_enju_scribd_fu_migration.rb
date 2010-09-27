class EnjuScribdFuMigration < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :ipaper_id, :integer
    add_column :manifestations, :ipaper_access_key, :string
  end

  def self.down
    remove_column :manifestations, :ipaper_id
    remove_column :manifestations, :ipaper_access_key
  end
end
