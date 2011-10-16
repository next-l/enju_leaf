class RenameEventTitleToName < ActiveRecord::Migration
  def self.up
    rename_column :events, :title, :name
  end

  def self.down
    rename_column :events, :name, :title
  end
end
