class AddErrorMsgOnPatronImportResults < ActiveRecord::Migration
  def self.up
    add_column :patron_import_results, :error_msg, :string
  end

  def self.down
    remove_column :patron_import_results, :error_msg
  end
end
