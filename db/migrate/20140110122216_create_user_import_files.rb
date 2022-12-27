class CreateUserImportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :user_import_files do |t|
      t.references :user, index: true
      t.text :note
      t.datetime :executed_at
      t.string :user_import_fingerprint
      t.string :edit_mode
      t.text :error_message

      t.timestamps
    end
  end
end
