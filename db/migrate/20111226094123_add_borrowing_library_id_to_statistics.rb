class AddBorrowingLibraryIdToStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :borrowing_library_id, :integer, :default => 0
  end

  def self.down
    remove_column :statistics, :borrowing_library_id
  end
end
