class CreateJpnoRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :jpno_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.references :manifestation, foreign_key: true, null: false

      t.timestamps
    end
  end
end
