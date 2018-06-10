class AddSaveSearchHistoryToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :save_search_history, :boolean, :default => false, :null => false
  end
end
