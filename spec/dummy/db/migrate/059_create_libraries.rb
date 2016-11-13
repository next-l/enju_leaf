class CreateLibraries < ActiveRecord::Migration
  def change
    create_table :libraries do |t|
      t.string :name, :null => false
      t.text :display_name
      t.string :short_display_name, :null => false
      t.string :zip_code
      t.text :street
      t.text :locality
      t.text :region
      t.string :telephone_number_1
      t.string :telephone_number_2
      t.string :fax_number
      t.text :note
      t.integer :call_number_rows, :default => 1, :null => false
      t.string :call_number_delimiter, :default => "|", :null => false
      t.integer :library_group_id, :default => 1, :null => false
      t.integer :users_count, :default => 0, :null => false
      t.integer :position
      t.integer :country_id

      t.timestamps
      t.datetime :deleted_at
    end
    add_index :libraries, :library_group_id
    add_index :libraries, :name, :unique => true
  end
end
