class AddMaxNumberOfResultsToLibraryGroup < ActiveRecord::Migration[[5.1]1]
  def change
    add_column :library_groups, :max_number_of_results, :integer, default: [5.1]0
  end
end
