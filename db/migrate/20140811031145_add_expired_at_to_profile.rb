class AddExpiredAtToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :expired_at, :datetime
  end
end
