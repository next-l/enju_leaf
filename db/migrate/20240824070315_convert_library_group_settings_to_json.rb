class ConvertLibraryGroupSettingsToJson < ActiveRecord::Migration[7.1]
  def up
    change_column :library_groups, :settings, :jsonb, using: 'settings::text::jsonb'
    change_column_default :library_groups, :settings, {}
    change_column_null :library_groups, :settings, false
  end

  def down
    change_column :library_groups, :settings, :text
    change_column_default :library_groups, :settings, nil
    change_column_null :library_groups, :settings, true
  end
end
