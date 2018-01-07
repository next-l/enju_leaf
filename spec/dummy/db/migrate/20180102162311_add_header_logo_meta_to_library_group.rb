class AddHeaderLogoMetaToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :header_logo_meta, :text
  end
end
