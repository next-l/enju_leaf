class AddAttachmentFingerprintToManifestation < ActiveRecord::Migration[5.0]
  def change
    add_column :manifestations, :attachment_fingerprint, :string
  end
end
