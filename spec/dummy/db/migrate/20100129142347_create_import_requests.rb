class CreateImportRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :import_requests do |t|
      t.string :isbn, index: true, null: false
      t.references :manifestation, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
