class EnjuScribdFuMigration < ActiveRecord::Migration
  def self.up
    add_column :attachment_files, :ipaper_id, :integer
    add_column :attachment_files, :ipaper_access_key, :string
  end

  def self.down
    remove_column :attachment_files, :ipaper_id
    remove_column :attachment_files, :ipaper_access_key
  end
end
