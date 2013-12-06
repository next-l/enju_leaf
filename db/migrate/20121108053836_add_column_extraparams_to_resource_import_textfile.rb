class AddColumnExtraparamsToResourceImportTextfile < ActiveRecord::Migration
  def change
    add_column :resource_import_textfiles, :extraparams, :string
  end
end
