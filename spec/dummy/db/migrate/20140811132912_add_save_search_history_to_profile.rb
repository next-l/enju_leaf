class AddSaveSearchHistoryToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :save_search_history, :boolean
  end
end
