class AddFingerprintToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :attachment_fingerprint, :string
  end
end
