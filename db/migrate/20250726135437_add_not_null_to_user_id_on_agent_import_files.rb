class AddNotNullToUserIdOnAgentImportFiles < ActiveRecord::Migration[7.1]
  def change
    change_column_null :agent_import_files, :user_id, false
    change_column_null :bookmarks, :user_id, false
    change_column_null :demands, :user_id, false
    change_column_null :event_export_files, :user_id, false
    change_column_null :event_import_files, :user_id, false
    change_column_null :import_requests, :user_id, false
    change_column_null :inventory_files, :user_id, false
    change_column_null :library_groups, :user_id, false
    change_column_null :manifestation_checkout_stats, :user_id, false
    change_column_null :manifestation_reserve_stats, :user_id, false
    change_column_null :news_posts, :user_id, false
    change_column_null :purchase_requests, :user_id, false
    change_column_null :resource_import_files, :user_id, false
    change_column_null :resource_export_files, :user_id, false
    change_column_null :subscriptions, :user_id, false
    change_column_null :user_checkout_stats, :user_id, false
    change_column_null :user_export_files, :user_id, false
    change_column_null :user_import_files, :user_id, false
    change_column_null :user_reserve_stats, :user_id, false
  end
end
