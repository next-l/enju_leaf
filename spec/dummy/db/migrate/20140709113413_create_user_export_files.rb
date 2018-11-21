class CreateUserExportFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :user_export_files do |t|
      t.references :user, foreign_key: true, null: false
      t.datetime :executed_at

      t.timestamps
    end
  end
end
