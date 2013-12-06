class AddCheckedAtToCheckin < ActiveRecord::Migration
  def change
    add_column :checkins, :checked_at, :datetime
  end
end
