class CreateIssnRecordAndManifestations < ActiveRecord::Migration[6.1]
  def change
    create_table :issn_record_and_manifestations, comment: '書誌とISSNの関係' do |t|
      t.references :issn_record, foreign_key: true, null: false
      t.references :manifestation, foreign_key: true, null: false, index: false

      t.timestamps
    end

    add_index :issn_record_and_manifestations, [:manifestation_id, :issn_record_id], unique: true, name: 'index_issn_record_and_manifestations_on_manifestation_id'
  end
end
