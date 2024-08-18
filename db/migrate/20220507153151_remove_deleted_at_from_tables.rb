class RemoveDeletedAtFromTables < ActiveRecord::Migration[6.1]
  def change
    %i(agents manifestations items subjects reserves libraries shelves
    user_groups events bookstores subscriptions users ).each do |table|
      remove_column table, :deleted_at, :timestamp
    end
  end
end
