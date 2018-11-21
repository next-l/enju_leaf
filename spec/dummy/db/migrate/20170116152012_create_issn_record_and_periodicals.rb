class CreateIssnRecordAndPeriodicals < ActiveRecord::Migration[5.1]
  def change
    create_table :issn_record_and_periodicals do |t|
      t.references :issn_record, foreign_key: true, on_delete: :cascade, null: false
      t.references :periodical, foreign_key: true, null: false, type: :uuid
      t.integer :position

      t.timestamps
    end
  end
end
