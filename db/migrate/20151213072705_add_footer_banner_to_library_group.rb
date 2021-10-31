# This migration comes from enju_library_engine (originally 20151213072705)
class AddFooterBannerToLibraryGroup < ActiveRecord::Migration[4.2]
  def up
    if defined?(Globalize)
      LibraryGroup.add_translation_fields! footer_banner: :text
    end

    if defined?(AwesomeHstoreTranslate)
      add_column :library_groups, :footer_banner, :hstore
    end
  end

  def down
    if defined?(Globalize)
      remove_column :library_group_translations, :footer_banner
    end

    if defined?(AwesomeHstoreTranslate)
      remove_column :library_groups, :footer_banner
    end
  end
end
