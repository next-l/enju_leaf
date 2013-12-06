class AddManifestationIdOnPurchaseRequests < ActiveRecord::Migration
  def self.up
    add_column :purchase_requests, :manifestation_id, :integer
  end

  def self.down
    remove_column :purchase_requests, :manifestation_id
  end
end
