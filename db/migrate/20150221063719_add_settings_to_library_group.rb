class AddSettingsToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :library_groups, :settings, :text
  end
end
