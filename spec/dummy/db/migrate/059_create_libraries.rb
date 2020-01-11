class CreateLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :libraries do |t|
      t.string :name, index: true, null: false
      t.string :short_display_name, null: false
      t.string :zip_code
      t.text :street
      t.text :locality
      t.text :region
      t.string :telephone_number_1
      t.string :telephone_number_2
      t.string :fax_number
      t.text :note, comment: '備考'
      t.integer :call_number_rows, default: 1, null: false
      t.string :call_number_delimiter, default: "|", null: false
      t.references :library_group, index: true, null: false
      t.integer :users_count, default: 0, null: false
      t.integer :position
      t.references :country

      t.timestamps
    end
  end
end
