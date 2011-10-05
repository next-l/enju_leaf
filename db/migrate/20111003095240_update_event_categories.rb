class UpdateEventCategories < ActiveRecord::Migration
  def self.up
    add_column :event_categories, :move_checkin_date, :integer
  end

  def self.down
  end
end
