class CreateDoiRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :doi_records do |t|
      t.string :body, null: false
      t.references :manifestation, null: false, foreign_key: true

      t.timestamps
    end
    add_index :doi_records, "lower(body), manifestation_id", unique: true
  end
end
