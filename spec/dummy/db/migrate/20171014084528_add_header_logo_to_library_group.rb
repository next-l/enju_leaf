class AddHeaderLogoToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_attachment :library_groups, :header_logo
  end
end
