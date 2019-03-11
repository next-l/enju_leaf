class CreateUserImportResults < ActiveRecord::Migration[5.2]
  def change
    create_table :user_import_results, id: :uuid do |t|
      t.references :user_import_file, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
