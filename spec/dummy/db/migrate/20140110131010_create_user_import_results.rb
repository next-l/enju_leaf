class CreateUserImportResults < ActiveRecord::Migration
  def change
    create_table :user_import_results do |t|
      t.references :user_import_file, index: true
      t.references :user, index: true
      t.text :body

      t.timestamps
    end
  end
end
