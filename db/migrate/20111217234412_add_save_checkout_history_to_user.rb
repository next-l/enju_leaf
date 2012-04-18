class AddSaveCheckoutHistoryToUser < ActiveRecord::Migration
  def change
    add_column :users, :save_checkout_history, :boolean
  end
end
