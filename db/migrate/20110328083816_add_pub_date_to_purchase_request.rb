class AddPubDateToPurchaseRequest < ActiveRecord::Migration
  def self.up
    add_column :purchase_requests, :pub_date, :string
  end

  def self.down
    remove_column :purchase_requests, :pub_date
  end
end
