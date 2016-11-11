class AddSettingsToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :settings, :jsonb
  end
end
