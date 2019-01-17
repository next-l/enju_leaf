class AddSettingsToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :settings, :jsonb
  end
end
