class ChangeExtraparamsType < ActiveRecord::Migration
  def up
    change_column :resource_import_textfiles, :extraparams, :text
  end

  def down
    change_column :resource_import_textfiles, :extraparams, :string
  end
end
