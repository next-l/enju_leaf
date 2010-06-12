class EnjuScribdFuMigration < ActiveRecord::Migration
  def self.up
    add_column :resources, :ipaper_id, :integer
    add_column :resources, :ipaper_access_key, :string
  end

  def self.down
    remove_column :resources, :ipaper_id
    remove_column :resources, :ipaper_access_key
  end
end
