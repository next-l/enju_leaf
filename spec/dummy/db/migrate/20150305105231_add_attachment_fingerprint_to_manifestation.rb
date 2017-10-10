class AddAttachmentFingerprintToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :attachment_fingerprint, :string
  end
end
