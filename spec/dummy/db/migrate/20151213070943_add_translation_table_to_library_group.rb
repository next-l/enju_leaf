# This migration comes from enju_library_engine (originally 20151213070943)
class AddTranslationTableToLibraryGroup < ActiveRecord::Migration[4.2]
  def up
    if defined?(Globalize)
      LibraryGroup.create_translation_table!({
        login_banner: :text
      }, {
        migrate_data: true
      })
    end

    if defined?(AwesomeHstoreTranslate)
      add_column :library_groups, :login_banner, :hstore
    end
  end

  def down
    if defined?(Globalize)
      LibraryGroup.drop_translation_table! migrate_data: true
    end

    if defined?(AwesomeHstoreTranslate)
      remove_column :library_groups, :login_banner
    end
  end
end
