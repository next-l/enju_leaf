class AddFailedToResourceImportTextresult < ActiveRecord::Migration
  def change
    add_column :resource_import_textresults, :failed, :boolean
  end
end
