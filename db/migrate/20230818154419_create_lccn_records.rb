class CreateLccnRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :lccn_records do |t|
      t.string :body, null: false
      t.references :manifestation, null: false, foreign_key: true

      t.timestamps
    end
    add_index :lccn_records, :body, unique: true
  end
end
