class ResourceImportTextresults < ActiveRecord::Migration
  def self.up
    create_table :resource_import_textresults do |t|
      t.integer :resource_import_textfile_id
      t.integer :manifestation_id
      t.integer :item_id
      t.text :body

      t.timestamps
    end

  end

  def self.down
    drop_table :resource_import_textresults
  end
end
