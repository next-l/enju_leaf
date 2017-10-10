class CreateUserImportResults < ActiveRecord::Migration[5.1]
  def change
    create_table :user_import_results do |t|
      t.references :user_import_file, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.text :body

      t.timestamps
    end
  end
end
