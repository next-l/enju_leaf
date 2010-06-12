class CreateSearchHistories < ActiveRecord::Migration
  def self.up
    create_table :search_histories do |t|
      t.integer :user_id
      t.string :operation, :default => 'searchRetrieve'
      t.float :version, :default => 1.2
      t.string :query
      t.integer :start_record
      t.integer :maximum_records
      t.string :record_packing
      t.string :record_schema
      t.integer :result_set_ttl
      t.string :stylesheet
      t.string :extra_request_data
      t.integer :number_of_records, :default => 0
      t.string :result_set_id
      t.integer :result_set_idle_time
      t.text :records
      t.integer :next_record_position
      t.text :diagnostics
      t.text :extra_response_data
      t.text :echoed_search_retrieve_request
      t.timestamps
    end
    add_index :search_histories, :user_id
  end

  def self.down
    drop_table :search_histories
  end
end
