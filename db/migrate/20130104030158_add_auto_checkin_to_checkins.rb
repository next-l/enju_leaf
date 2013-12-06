class AddAutoCheckinToCheckins < ActiveRecord::Migration
  def change
    add_column :checkins, :auto_checkin, :boolean, :default => false
  end
end
