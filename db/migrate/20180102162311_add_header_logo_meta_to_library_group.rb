class AddHeaderLogoMetaToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :library_groups, :header_logo_meta, :text
  end
end
