class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
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
      t.decimal :price # TODO: 通貨単位
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
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.boolean :repository_content, :default => false, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.integer :required_role_id, :default => 1, :null => false
      t.string :state
      t.integer :required_score, :default => 0, :null => false
      t.integer :frequency_id, :default => 1, :null => false
      t.boolean :subscription_master, :default => false, :null => false
      t.integer :series_statement_id
    end
    add_index :resources, :carrier_type_id
    add_index :resources, :required_role_id
    add_index :resources, :isbn
    add_index :resources, :nbn
    add_index :resources, :lccn
    add_index :resources, :oclc_number
    add_index :resources, :issn
    add_index :resources, :access_address
    add_index :resources, :frequency_id
    add_index :resources, :series_statement_id
    add_index :resources, :manifestation_identifier
    add_index :resources, :updated_at
  end

  def self.down
    drop_table :resources
  end
end
