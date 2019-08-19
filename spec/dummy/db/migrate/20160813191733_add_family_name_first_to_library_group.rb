class AddFamilyNameFirstToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :family_name_first, :boolean, default: true
  end
end
