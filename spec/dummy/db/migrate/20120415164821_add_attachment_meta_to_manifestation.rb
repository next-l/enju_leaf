class AddAttachmentMetaToManifestation < ActiveRecord::Migration[5.0]
  def change
    add_column :manifestations, :attachment_meta, :text
  end
end
