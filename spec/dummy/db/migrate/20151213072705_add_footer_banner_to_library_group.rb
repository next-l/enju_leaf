class AddFooterBannerToLibraryGroup < ActiveRecord::Migration
  def up
    LibraryGroup.add_translation_fields! footer_banner: :text
  end

  def down
    remove_column :library_group_translations, :footer_banner
  end
end
