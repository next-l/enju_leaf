class AddAttachmentMetaToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :attachment_meta, :text
  end
end
