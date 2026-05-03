class AddManifestationIdToIssnRecords < ActiveRecord::Migration[8.1]
  def up
    add_reference :issn_records, :manifestation, foreign_key: true, index: false

    IssnRecordAndManifestation.find_each do |i|
      i.issn_record.update_column(:manifestation_id, i.manifestation_id)
    end

    change_column_null :issn_records, :manifestation_id, false
    add_index :issn_records, [ :manifestation_id, :body ], unique: true
  end

  def down
    remove_reference :issn_records, :manifestation
  end
end
