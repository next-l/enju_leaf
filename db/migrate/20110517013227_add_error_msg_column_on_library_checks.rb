class AddErrorMsgColumnOnLibraryChecks < ActiveRecord::Migration
  def self.up
    add_column :library_checks, :error_msg, :string
  end

  def self.down
    remove_column :library_checks, :error_msg
  end
end
