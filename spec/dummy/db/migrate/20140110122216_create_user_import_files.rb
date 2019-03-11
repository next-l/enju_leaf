class CreateUserImportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_import_files, id: :uuid do |t|
      t.references :user, foreign_key: true
      t.text :note
      t.datetime :executed_at
      t.string :edit_mode
      t.text :error_message

      t.timestamps
    end
  end
end
