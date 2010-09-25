class CreatePatronImportResults < ActiveRecord::Migration
  def self.up
    create_table :patron_import_results do |t|
      t.integer :patron_import_file_id
      t.integer :patron_id
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :patron_import_results
  end
end
