class AddReasonOnInterLibraryLoan < ActiveRecord::Migration
  def self.up
    add_column :inter_library_loans, :reason, :integer
  end

  def self.down
    remove_column :inter_library_loans, :reason
  end
end
