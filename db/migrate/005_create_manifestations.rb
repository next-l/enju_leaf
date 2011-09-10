class CreateManifestations < ActiveRecord::Migration
  def self.up
    create_table :manifestations do |t|
      t.text :original_title, :null => false
      t.text :title_alternative
      t.text :title_transcription
      t.string :classification_number
      t.string :manifestation_identifier
      t.datetime :date_of_publication
      t.datetime :copyright_date
      t.timestamps
      t.datetime :deleted_at
      t.string :access_address
      t.integer :language_id, :default => 1, :null => false
      t.integer :carrier_type_id, :default => 1, :null => false
      t.integer :extent_id, :default => 1, :null => false
      t.integer :start_page
      t.integer :end_page
      t.decimal :height
      t.decimal :width
      t.decimal :depth
      t.string :isbn
      t.string :isbn10
      t.string :wrong_isbn
      t.string :nbn
      t.string :lccn
      t.string :oclc_number
      t.string :issn
      t.integer :price # TODO: 通貨単位
      #t.text :filename
      #t.string :content_type
      #t.integer :size
      t.text :fulltext
      t.string :volume_number_list
      t.string :issue_number_list
      t.string :serial_number_list
      t.integer :edition
      t.text :note
      t.integer :produces_count, :default => 0, :null => false
      t.integer :exemplifies_count, :default => 0, :null => false
      t.integer :embodies_count, :default => 0, :null => false
      t.integer :exemplifies_count, :default => 0, :null => false
      t.integer :work_has_subjects_count, :default => 0, :null => false
      t.boolean :repository_content, :default => false, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.integer :required_role_id, :default => 1, :null => false
      t.string :state
      t.integer :required_score, :default => 0, :null => false
      t.integer :frequency_id, :default => 1, :null => false
      t.boolean :subscription_master, :default => false, :null => false
    end
    add_index :manifestations, :carrier_type_id
    add_index :manifestations, :required_role_id
    add_index :manifestations, :isbn
    add_index :manifestations, :nbn
    add_index :manifestations, :lccn
    add_index :manifestations, :oclc_number
    add_index :manifestations, :issn
    add_index :manifestations, :access_address
    add_index :manifestations, :frequency_id
    add_index :manifestations, :manifestation_identifier
    add_index :manifestations, :updated_at
  end

  def self.down
    drop_table :manifestations
  end
end
