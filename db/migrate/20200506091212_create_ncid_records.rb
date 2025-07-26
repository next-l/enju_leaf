class CreateNcidRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :ncid_records do |t|
      t.references :manifestation, null: false, foreign_key: true
      t.string :body, null: false

      t.timestamps
    end

    add_index :ncid_records, :body, unique: true
  end
end
