class CreateUserExportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_export_files, id: :uuid do |t|
      t.references :user, foreign_key: true
      t.datetime :executed_at

      t.timestamps
    end
  end
end
