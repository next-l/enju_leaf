class AddAttachmentAttachmentToCarrierTypes < ActiveRecord::Migration[4.2]
  def change
    change_table :carrier_types do |t|
      t.string :attachment_content_type
      t.string :attachment_file_name
      t.bigint :attachment_file_size
      t.datetime :attachment_updated_at
    end
  end
end
