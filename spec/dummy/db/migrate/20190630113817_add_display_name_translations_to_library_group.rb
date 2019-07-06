class AddDisplayNameTranslationsToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_types, :display_name_translations, :jsonb, default: {}, null: false
    add_column :libraries, :display_name_translations, :jsonb, default: {}, null: false
    add_column :library_groups, :display_name_translations, :jsonb, default: {}, null: false
    add_column :request_status_types, :display_name_translations, :jsonb, default: {}, null: false
    add_column :request_types, :display_name_translations, :jsonb, default: {}, null: false
    add_column :search_engines, :display_name_translations, :jsonb, default: {}, null: false
    add_column :shelves, :display_name_translations, :jsonb, default: {}, null: false
    add_column :user_groups, :display_name_translations, :jsonb, default: {}, null: false
  end
end
