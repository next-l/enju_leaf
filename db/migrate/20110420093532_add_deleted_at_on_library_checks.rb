class AddDeletedAtOnLibraryChecks < ActiveRecord::Migration
  def self.up
    remove_column :library_checks, :status
    add_column :library_checks, :deleted_at, :datetime
    add_column :library_checks, :state, :string
  end

  def self.down
    add_column :library_checks, :status, :integer
    remove_column :library_checks, :deleted_at
    remove_column :library_checks, :state
  end
end
