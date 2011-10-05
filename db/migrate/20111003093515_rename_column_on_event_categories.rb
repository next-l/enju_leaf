class RenameColumnOnEventCategories < ActiveRecord::Migration
  def self.up
    rename_column :event_categories, :checkin_able, :checkin_ng
  end

  def self.down
  end
end
