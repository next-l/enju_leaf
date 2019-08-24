class CreateResourceImportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_import_files do |t|
      t.references :user, foreign_key: true
      t.text :note
      t.datetime :executed_at

      t.timestamps
    end
  end
end
