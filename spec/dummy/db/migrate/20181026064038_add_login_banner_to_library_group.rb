class AddLoginBannerToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :login_banner_translations, :jsonb, default: {}, null: false
    add_column :library_groups, :footer_banner_translations, :jsonb, default: {}, null: false
  end
end
