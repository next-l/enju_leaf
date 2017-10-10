class CreateUserImportFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :user_import_files do |t|
      t.references :user, foreign_key: true, null: false
      t.text :note
      t.string :edit_mode
      t.text :error_message

      t.timestamps
    end
  end
end
