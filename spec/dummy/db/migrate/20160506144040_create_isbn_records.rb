class CreateIsbnRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :isbn_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.string :isbn_type
      t.string :source
      t.references :manifestation, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
