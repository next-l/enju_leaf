class AddDisplayNameToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :display_name, :text
  end

  def self.down
    remove_column :events, :display_name
  end
end
