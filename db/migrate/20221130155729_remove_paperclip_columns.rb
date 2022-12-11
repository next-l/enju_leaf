class RemovePaperclipColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :agent_import_files, :agent_import_file_name
    remove_column :agent_import_files, :agent_import_content_type
    remove_column :agent_import_files, :agent_import_file_size
    remove_column :agent_import_files, :agent_import_updated_at
    remove_column :agent_import_files, :content_type
    remove_column :agent_import_files, :size

    remove_column :carrier_types, :attachment_file_name
    remove_column :carrier_types, :attachment_content_type
    remove_column :carrier_types, :attachment_file_size
    remove_column :carrier_types, :attachment_updated_at

    remove_column :event_export_files, :event_export_file_name
    remove_column :event_export_files, :event_export_content_type
    remove_column :event_export_files, :event_export_file_size
    remove_column :event_export_files, :event_export_updated_at

    remove_column :event_import_files, :event_import_file_name
    remove_column :event_import_files, :event_import_content_type
    remove_column :event_import_files, :event_import_file_size
    remove_column :event_import_files, :event_import_updated_at
    remove_column :event_import_files, :content_type
    remove_column :event_import_files, :size

    remove_column :inventory_files, :inventory_file_name
    remove_column :inventory_files, :inventory_content_type
    remove_column :inventory_files, :inventory_file_size
    remove_column :inventory_files, :inventory_updated_at
    remove_column :inventory_files, :filename
    remove_column :inventory_files, :content_type
    remove_column :inventory_files, :size

    remove_column :library_groups, :header_logo_file_name
    remove_column :library_groups, :header_logo_content_type
    remove_column :library_groups, :header_logo_file_size
    remove_column :library_groups, :header_logo_updated_at
    remove_column :library_groups, :header_logo_meta

    remove_column :manifestations, :attachment_file_name
    remove_column :manifestations, :attachment_content_type
    remove_column :manifestations, :attachment_file_size
    remove_column :manifestations, :attachment_updated_at
    remove_column :manifestations, :attachment_meta

    remove_column :picture_files, :picture_file_name
    remove_column :picture_files, :picture_content_type
    remove_column :picture_files, :picture_file_size
    remove_column :picture_files, :picture_updated_at
    remove_column :picture_files, :picture_meta

    remove_column :resource_export_files, :resource_export_file_name
    remove_column :resource_export_files, :resource_export_content_type
    remove_column :resource_export_files, :resource_export_file_size
    remove_column :resource_export_files, :resource_export_updated_at

    remove_column :resource_import_files, :resource_import_file_name
    remove_column :resource_import_files, :resource_import_content_type
    remove_column :resource_import_files, :resource_import_file_size
    remove_column :resource_import_files, :resource_import_updated_at
    remove_column :resource_import_files, :content_type
    remove_column :resource_import_files, :size

    remove_column :user_export_files, :user_export_file_name
    remove_column :user_export_files, :user_export_content_type
    remove_column :user_export_files, :user_export_file_size
    remove_column :user_export_files, :user_export_updated_at

    remove_column :user_import_files, :user_import_file_name
    remove_column :user_import_files, :user_import_content_type
    remove_column :user_import_files, :user_import_file_size
    remove_column :user_import_files, :user_import_updated_at
  end
end
