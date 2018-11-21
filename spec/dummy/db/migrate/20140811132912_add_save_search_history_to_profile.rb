class AddSaveSearchHistoryToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :save_search_history, :boolean
  end
end
