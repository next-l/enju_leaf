class AddHeaderLogoToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :library_groups, :header_logo_content_type, :string
    add_column :library_groups, :header_logo_file_name, :string
    add_column :library_groups, :header_logo_file_size, :integer
  end
end
