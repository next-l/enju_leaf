class RenameColumnForManifestationIdToTableOfContents < ActiveRecord::Migration
  def up
    rename_column :table_of_contents, :manifestaion_id, :manifestation_id
  end

  def down
    rename_column :table_of_contents, :manifestation_id, :manifestaion_id
  end
end
