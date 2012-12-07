class CheangeUserIdNullToPurchaseRequests < ActiveRecord::Migration
  def up
    change_column :purchase_requests, :user_id, :integer, null: true
  end

  def down
    change_column :purchase_requests, :user_id, :integer, null: false
  end
end
