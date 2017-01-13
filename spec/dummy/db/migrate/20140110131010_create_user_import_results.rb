class CreateUserImportResults < ActiveRecord::Migration
  def change
    create_table :user_import_results do |t|
      t.integer :user_import_file_id
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end
end
