class AddCheckinAbleOnEventCategories < ActiveRecord::Migration
  def self.up
    add_column :event_categories, :checkin_able, :boolean, :default => false
  end

  def self.down
  end
end
