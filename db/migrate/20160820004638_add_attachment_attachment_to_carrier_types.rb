class AddAttachmentAttachmentToCarrierTypes < ActiveRecord::Migration[4.2]
  def up
    change_table :carrier_types do |t|
      t.string :attachment_content_type
      t.string :attachment_file_name
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
    end
  end

  def down
    remove_column :carrier_types, :attachment_content_type
    remove_column :carrier_types, :attachment_file_name
    remove_column :carrier_types, :attachment_file_size
    remove_column :carrier_types, :attachment_updated_at
  end
end
