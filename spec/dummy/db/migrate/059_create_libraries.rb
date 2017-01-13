class CreateLibraries < ActiveRecord::Migration[5.0]
  def change
    create_table :libraries, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false, index: {unique: true}
      t.jsonb :display_name_translations
      t.jsonb :short_display_name_translations
      t.string :zip_code
      t.text :street
      t.text :locality
      t.text :region
      t.string :telephone_number_1
      t.string :telephone_number_2
      t.string :fax_number
      t.text :note
      t.integer :call_number_rows, default: 1, null: false
      t.string :call_number_delimiter, default: "|", null: false
      t.integer :library_group_id, default: 1, null: false
      t.integer :users_count, default: 0, null: false
      t.integer :position
      t.integer :country_id

      t.timestamps
      t.datetime :deleted_at
    end
    add_index :libraries, :library_group_id
  end
end
