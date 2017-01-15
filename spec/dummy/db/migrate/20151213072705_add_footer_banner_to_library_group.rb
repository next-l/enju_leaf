class AddFooterBannerToLibraryGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :library_groups, :footer_banner_translations, :jsonb
  end
end
