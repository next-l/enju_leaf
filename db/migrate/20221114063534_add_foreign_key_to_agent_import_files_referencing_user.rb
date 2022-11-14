class AddForeignKeyToAgentImportFilesReferencingUser < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :agent_import_files, :users
    add_foreign_key :baskets, :users
    add_foreign_key :bookmarks, :users
    add_foreign_key :event_export_files, :users
    add_foreign_key :import_requests, :users
    add_foreign_key :inventory_files, :users
    add_foreign_key :news_posts, :users
    add_foreign_key :resource_export_files, :users
    add_foreign_key :resource_import_files, :users
    add_foreign_key :subscriptions, :users
    add_foreign_key :user_export_files, :users
    add_foreign_key :user_import_files, :users
  end
end
