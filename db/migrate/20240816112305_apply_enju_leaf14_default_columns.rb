class ApplyEnjuLeaf14DefaultColumns < ActiveRecord::Migration[6.1]
  def up
    change_column :carrier_types, :attachment_file_size, :bigint
    change_column :event_export_files, :event_export_file_size, :bigint
    change_column :resource_export_files, :resource_export_file_size, :bigint
    change_column :user_export_files, :user_export_file_size, :bigint
    change_column :library_group_translations, :created_at, :timestamp, precision: 6
    change_column :library_group_translations, :updated_at, :timestamp, precision: 6
    change_column :library_groups, :header_logo_file_size, :bigint
  end

  def down
    change_column :carrier_types, :attachment_file_size, :integer
    change_column :event_export_files, :event_export_file_size, :integer
    change_column :resource_export_files, :resource_export_file_size, :integer
    change_column :user_export_files, :user_export_file_size, :integer
    change_column :library_group_translations, :created_at, :timestamp
    change_column :library_group_translations, :updated_at, :timestamp
    change_column :library_groups, :header_logo_file_size, :integer
  end
end
