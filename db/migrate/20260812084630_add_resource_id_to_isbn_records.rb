class AddResourceIdToIsbnRecords < ActiveRecord::Migration[8.1]
  def up
    add_reference :isbn_records, :resource, null: true, polymorphic: true, index: false
    add_reference :issn_records, :resource, null: true, polymorphic: true, index: false

    remove_index :issn_records, :body, unique: true
    add_index :issn_records, :body
    add_index :isbn_records, [ :resource_id, :resource_type, :body ], unique: true
    add_index :issn_records, [ :resource_id, :resource_type, :body ], unique: true

    IsbnRecordAndManifestation.find_each do |i|
      i.isbn_record.update_column(:resource_id, i.manifestation_id)
      i.isbn_record.update_column(:resource_type, "Manifestation")
      i.destroy unless i.isbn_record
      i.destroy unless i.manifestation
    end

    IssnRecordAndManifestation.find_each do |i|
      i.issn_record.update_column(:resource_id, i.manifestation_id)
      i.issn_record.update_column(:resource_type, "Manifestation")
      i.destroy unless i.issn_record
      i.destroy unless i.manifestation
    end

    change_column_null :isbn_records, :resource_id, false
    change_column_null :issn_records, :resource_id, false
    change_column_null :isbn_records, :resource_type, false
    change_column_null :issn_records, :resource_type, false
  end

  def down
    remove_reference :isbn_records, :resource, polymorphic: true
    remove_reference :issn_records, :resource, polymorphic: true
    remove_index :issn_records, :body
    add_index :issn_records, :body, unique: true
  end
end
