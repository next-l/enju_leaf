class RenameLoginBannerToOldLoginBanner < ActiveRecord::Migration
  def change
    rename_column :library_groups, :login_banner, :old_login_banner
  end
end
