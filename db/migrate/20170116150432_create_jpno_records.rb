class CreateJpnoRecords < ActiveRecord::Migration[5.2]
  def up
    create_table :jpno_records, if_not_exists: true do |t|
      t.string :body, index: {unique: true}, null: false
      t.references :manifestation, foreign_key: true, null: false

      t.timestamps
    end
  end

  def down
    drop_table :jpno_records
  end
end
