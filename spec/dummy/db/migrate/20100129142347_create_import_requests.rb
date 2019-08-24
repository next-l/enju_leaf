class CreateImportRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :import_requests do |t|
      t.string :isbn
      t.references :manifestation, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :import_requests, :isbn
  end
end
