class AddFooterBannerToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :footer_banner, :jsonb
  end
end
