class AddPubYearFacetRangeIntervalToLibraryGroup < ActiveRecord::Migration
  def change
    add_column :library_groups, :pub_year_facet_range_interval, :integer, default: 10
  end
end
