class AddHeaderLogoToLibraryGroup < ActiveRecord::Migration
  def change
    add_attachment :library_groups, :header_logo
  end
end
