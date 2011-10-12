class AddErrorMsgOnEventImportResults < ActiveRecord::Migration
  def self.up
    add_column :event_import_results, :error_msg, :string
  end

  def self.down
    remove_column :event_import_results, :error_msg
  end
end
