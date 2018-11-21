class CreateIssnRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :issn_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.string :issn_type
      t.string :source
      t.references :manifestation, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
