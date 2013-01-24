class AddExtraparamsToResourceImportTextresults < ActiveRecord::Migration
  def change
    add_column :resource_import_textresults, :extraparams, :string
  end
end
