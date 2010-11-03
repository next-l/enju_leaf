class AddTitleToPatron < ActiveRecord::Migration
  def self.up
    add_column :patrons, :title, :string
  end

  def self.down
    remove_column :patrons, :title
  end
end
