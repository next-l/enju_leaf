class AddAttachmentAttachmentToCarrierTypes < ActiveRecord::Migration[4.2]
  def self.up
    change_table :carrier_types do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :carrier_types, :attachment
  end
end
