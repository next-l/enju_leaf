class CreateIsbnRecordAndManifestations < ActiveRecord::Migration[6.1]
  def change
    create_table :isbn_record_and_manifestations, comment: '書誌とISBNの関係' do |t|
      t.references :isbn_record, foreign_key: true, null: false
      t.references :manifestation, foreign_key: true, null: false, index: false

      t.timestamps
    end

    add_index :isbn_record_and_manifestations, [:manifestation_id, :isbn_record_id], unique: true, name: 'index_isbn_record_and_manifestations_on_manifestation_id'
  end
end
