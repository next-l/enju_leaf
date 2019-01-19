class AddAttachmentMetaToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :attachment_meta, :text
  end
end
