class CreateShelfImportFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :shelf_import_files do |t|
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
