class AddColumnForErrorMsgToResourceImportTextresults < ActiveRecord::Migration
  def self.up
    add_column :resource_import_textresults, :error_msg, :text
  end

  def self.down
    remove_column :resource_import_textresults, :error_msg
  end
end
