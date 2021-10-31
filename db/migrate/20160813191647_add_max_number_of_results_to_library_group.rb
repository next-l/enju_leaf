class AddMaxNumberOfResultsToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :library_groups, :max_number_of_results, :integer, default: 1000
  end
end
