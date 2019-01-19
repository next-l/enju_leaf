class CreateImportRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :import_requests do |t|
      t.string :isbn, index: true
      t.references :manifestation
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
