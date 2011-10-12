class AddErrorMsgOnResourceImportResults < ActiveRecord::Migration
  def self.up
    add_column :resource_import_results, :error_msg, :string
  end

  def self.down
    remove_column :resource_import_results, :error_msg
  end
end
