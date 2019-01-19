class CreateManifestations < ActiveRecord::Migration[5.2]
  def change
    create_table :manifestations do |t|
      t.text :original_title, null: false
      t.text :title_alternative
      t.text :title_transcription
      t.string :classification_number
      t.string :manifestation_identifier, index: {unique: true}
      t.datetime :date_of_publication, index: true
      t.datetime :copyright_date
      t.timestamps
      t.string :access_address, index: true
      t.integer :language_id, default: 1, null: false
      t.integer :carrier_type_id, default: 1, null: false
      t.integer :start_page
      t.integer :end_page
      t.integer :height
      t.integer :width
      t.integer :depth
      t.integer :price # TODO: 通貨単位
      t.text :fulltext
      t.string :volume_number_string
      t.string :issue_number_string
      t.string :serial_number_string
      t.integer :edition
      t.text :note
      t.boolean :repository_content, default: false, null: false
      t.integer :lock_version, default: 0, null: false
      t.integer :required_role_id, default: 1, null: false
      t.integer :frequency_id, default: 1, null: false
      t.boolean :subscription_master, default: false, null: false
    end
    add_index :manifestations, :updated_at
  end
end
