class AddHeaderLogoDataToLibraryGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :library_groups, :header_logo_data, :jsonb
  end
end
