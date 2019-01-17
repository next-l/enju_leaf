class AddMaxNumberOfResultsToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :max_number_of_results, :integer, default: 500
  end
end
