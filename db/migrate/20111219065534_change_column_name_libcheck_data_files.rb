class ChangeColumnNameLibcheckDataFiles < ActiveRecord::Migration
  def self.up
    rename_column(:libcheck_data_files, :uploaded_at, :updated_at)
  end

  def self.down
  end
end
