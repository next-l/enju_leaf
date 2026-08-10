class RemoveStartedAtFromBookmarkStats < ActiveRecord::Migration[7.2]
  def change
    [ :bookmark_stats, :manifestation_checkout_stats, :manifestation_reserve_stats, :user_checkout_stats, :user_reserve_stats ].each do |table|
      remove_column table, :started_at, :datetime
      remove_column table, :completed_at, :datetime
      change_column_null table, :start_date, false
      change_column_null table, :end_date, false
    end
  end
end
