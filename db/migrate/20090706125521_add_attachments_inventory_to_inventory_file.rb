class AddAttachmentsInventoryToInventoryFile < ActiveRecord::Migration[4.2]
  def up
    add_column :inventory_files, :inventory_file_name, :string, if_not_exists: true
    add_column :inventory_files, :inventory_content_type, :string, if_not_exists: true
    add_column :inventory_files, :inventory_file_size, :integer, if_not_exists: true
    add_column :inventory_files, :inventory_updated_at, :datetime, if_not_exists: true
  end

  def down
    remove_column :inventory_files, :inventory_file_name
    remove_column :inventory_files, :inventory_content_type
    remove_column :inventory_files, :inventory_file_size
    remove_column :inventory_files, :inventory_updated_at
  end
end
