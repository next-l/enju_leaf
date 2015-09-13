class AddAttachmentIdToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :attachment_id, :string
    rename_column :manifestations, :attachment_file_size, :attachment_size
    add_index :manifestations, :attachment_id
  end
end
