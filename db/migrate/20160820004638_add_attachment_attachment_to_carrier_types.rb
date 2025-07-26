class AddAttachmentAttachmentToCarrierTypes < ActiveRecord::Migration[4.2]
  def up
    change_table :carrier_types do |t|
      t.attachment :attachment
    end
  end

  def down
    remove_attachment :carrier_types, :attachment
  end
end
