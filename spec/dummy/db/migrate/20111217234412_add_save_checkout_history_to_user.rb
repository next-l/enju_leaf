class AddSaveCheckoutHistoryToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :save_checkout_history, :boolean, default: false, null: false
  end
end
