class UpdateInterLibraryLoans < ActiveRecord::Migration
  def self.up
    rename_column :inter_library_loans, :borrowing_library_id, :to_library_id
    InterLibraryLoan.update_all ["to_library_id = ?", 0]
    add_column :inter_library_loans, :from_library_id, :integer, :null => false
  end

  def self.down
    renane_column :inter_library_loans, :to_library_id, :borrowing_library_id
    remove_column :inter_library_loans, :from_library_id
  end
end
