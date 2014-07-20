class AddSaveSearchHistoryToUser < ActiveRecord::Migration
  def change
    add_column :users, :save_search_history, :boolean, :default => false, :null => false
  end
end
