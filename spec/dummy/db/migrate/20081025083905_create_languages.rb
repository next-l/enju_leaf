class CreateLanguages < ActiveRecord::Migration[5.1]

  # ISO 639 is the set of international standards that lists short codes for language names.
  # Note this doesn't include macrolanguages (dialects)
  # Information on macrolanguages http://en.wikipedia.org/wiki/ISO_639_macrolanguage

  def change
    create_table :languages do |t|
      t.string :name, :null => false
      t.string :native_name
      t.text :display_name
      t.string :iso_639_1,        :size => 3
      t.string :iso_639_2,        :size => 3
      t.string :iso_639_3,        :size => 3
      t.text :note
      t.integer :position
    end
    add_index :languages, :name, :unique => true
    add_index :languages, :iso_639_1
    add_index :languages, :iso_639_2
    add_index :languages, :iso_639_3
  end
end
