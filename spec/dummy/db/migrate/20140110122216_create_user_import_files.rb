class CreateUserImportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_import_files do |t|
      t.references :user, foreign_key: true
      t.text :note, comment: '備考'
      t.datetime :executed_at
      t.string :user_import_fingerprint
      t.string :edit_mode
      t.text :error_message

      t.timestamps
    end
  end
end
