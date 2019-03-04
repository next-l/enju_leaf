class CreateResourceImportResults < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_import_results, id: :uuid do |t|
      t.references :resource_import_file, foreign_key: true, type: :uuid
      t.references :manifestation, type: :uuid
      t.references :item, type: :uuid
      t.text :body

      t.timestamps
    end
  end
end
