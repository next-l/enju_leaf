class AddManifestationIdToIsbnRecords < ActiveRecord::Migration[8.1]
  def up
    add_reference :isbn_records, :manifestation, foreign_key: true, index: false

    IsbnRecordAndManifestation.find_each do |i|
      i.isbn_record.update_column(:manifestation_id, i.manifestation_id)
    end

    change_column_null :isbn_records, :manifestation_id, false
    add_index :isbn_records, [ :manifestation_id, :body ], unique: true
  end

  def down
    remove_reference :isbn_records, :manifestation
  end
end
