class AddAttachmentMetaToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :attachment_meta, :text
  end
end
